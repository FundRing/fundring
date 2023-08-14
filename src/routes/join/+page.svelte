<script lang="ts">
  // @ts-ignore-next-line
  import { env } from '$env/dynamic/public'
  import {
    getNetwork,
    getWalletClient,
    signMessage,
    switchNetwork
  } from '@wagmi/core'
  import clipboardCopy from 'clipboard-copy'
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { parseEther } from 'viem'
  import { filecoinCalibration } from 'viem/chains'
  import { Web3Storage } from 'web3.storage'

  import { sessionStore } from '$src/stores'
  import { slugify } from '$lib/utils'
  import { addNotification } from '$lib/notifications'
  import { NETWORK_MAP, checkStatusOfPendingTX } from '$lib/contract'
  import { abi } from '$contracts/FundRingProject.sol/FundRingProject.json'
  import { CONTRACT_BYTECODE } from './lib/bytecode'
  // import FundRingWidget from '$components/FundRingWidget/FundRingWidget.svelte'
  import JoinForm from '$components/forms/Join.svelte'
  import IntroBlurb from './components/IntroBlurb.svelte'
  import Step from './components/Step.svelte'

  let currentStep = 1
  // let showWidgetPreview = false
  const loadingText = ['processing', 'sit tight', 'network speed may vary']

  // Create web3 storage client
  const web3StorageClient = new Web3Storage({
    token: env.PUBLIC_WEB3_STORAGE_KEY
  })

  // Create store to save project details
  const projectDetails = writable({
    name: null,
    repoLink: null,
    fundingGoal: null,
    frequency: null,
    signature: null,
    slug: null
  })

  // Save the `projectDetails` to the store and increment the `currentStep`
  const handleDetailsSubmit = event => {
    const formData = new FormData(event.target)

    const projectName = formData.get('project_name')
    const repoLink = formData.get('repo_link')
    const fundingGoal = formData.get('funding_goal')
    const frequency = formData.get('frequency')

    projectDetails.update(state => ({
      ...state,
      name: projectName,
      repoLink,
      fundingGoal,
      frequency,
      slug: slugify(projectName as string)
    }))
    addNotification('Details submitted', 'success')
    currentStep = 2
    document.getElementById('step2').scrollIntoView({ behavior: 'smooth' })
  }

  // Connect via WalletConnect
  let account = $sessionStore.ethereumClient.getAccount()
  $: connectButtonText = account.isConnected
    ? 'Sign Proof'
    : 'Connect Your Wallet'
  const unsubscribeEvents = $sessionStore.web3modal.subscribeEvents(
    newState => {
      if (newState.name === 'ACCOUNT_CONNECTED') {
        connectButtonText = 'Sign Proof'
        document.getElementById('step2').scrollIntoView({ behavior: 'smooth' })
      } else {
        connectButtonText = 'Connect Your Wallet'
      }
    }
  )

  // Either connect the user's wallet client or sign the proof
  const handleConnectOrSign = async () => {
    try {
      account = $sessionStore.ethereumClient.getAccount()
      if (account.isConnected) {
        const signature = await signMessage({
          message: `Create my ${$projectDetails.slug}.fundring proof`
        })
        projectDetails.update(state => ({
          ...state,
          signature
        }))
        addNotification('Signature successful', 'success')
        currentStep = 3
        document.getElementById('step3').scrollIntoView({ behavior: 'smooth' })
      } else {
        await $sessionStore.web3modal.openModal({
          route: 'ConnectWallet'
        })
      }
    } catch (error) {
      console.error(error)
    }
  }

  // Download `<project-slug>.fundring` file with signed proof
  const handleDownloadFundringFile = async () => {
    const blob = new Blob([$projectDetails.signature], { type: 'octet/stream' })
    const fileURL = URL.createObjectURL(blob)

    const downloadLink = document.createElement('a')
    downloadLink.href = fileURL
    downloadLink.download = `${$projectDetails.slug}.fundring`
    downloadLink.click()
    URL.revokeObjectURL(fileURL)

    currentStep = 4
    document.getElementById('step4').scrollIntoView({ behavior: 'smooth' })
  }

  // Verify fundring file is in repo
  const handleVerifyFundring = async () => {
    const repoPath = $projectDetails.repoLink
      .split('github.com')[1]
      .split('.git')[0]
    const response = await fetch(
      `https://raw.githubusercontent.com${repoPath}/main/${$projectDetails.slug}.fundring`
    )
    const blob = await response.blob()
    const text = await blob.text()

    if (
      text.trim().toLowerCase() ===
      $projectDetails.signature.trim().toLowerCase()
    ) {
      addNotification(
        `Your ${$projectDetails.slug}.fundring file has been verified`,
        'success'
      )
      currentStep = 5
      document.getElementById('step5').scrollIntoView({ behavior: 'smooth' })
    } else {
      addNotification(
        `Your ${$projectDetails.slug}.fundring file could not be verified`,
        'error'
      )
    }
  }

  // Deploy generated contract with form values
  let loading = false
  let deployedAddress
  let i = 0
  const handleDeployContract = async () => {
    loading = true

    const interval = setInterval(() => {
      i == 2 ? (i = 0) : i++
    }, 1400)

    try {
      const { chain } = getNetwork()

      // Prompt the user to switch networks if they are not on Calibration
      if (chain.id !== Number(NETWORK_MAP.testnet.chainId)) {
        try {
          const network = await switchNetwork({
            chainId: Number(NETWORK_MAP.testnet.chainId)
          })
        } catch (error) {
          console.error(error)
          console.log('could not programmitically switch network')
        }
      }

      const client = await getWalletClient()
      const hash = await client.deployContract({
        abi,
        bytecode: CONTRACT_BYTECODE,
        args: [
          $projectDetails.name,
          $projectDetails.repoLink,
          parseEther($projectDetails.fundingGoal),
          $projectDetails.frequency
        ],
        chain: filecoinCalibration
      })

      const receipt = await checkStatusOfPendingTX(hash)

      loading = false
      deployedAddress = receipt.contractAddress

      addNotification(
        `Deployed to ${receipt.contractAddress}`,
        'success',
        10000
      )

      currentStep = 6

      const file = new File(
        [
          JSON.stringify({
            name: $projectDetails.name,
            repoLink: $projectDetails.repoLink,
            fundingGoal: $projectDetails.fundingGoal,
            frequency: $projectDetails.frequency,
            slug: $projectDetails.slug,
            deployedAddress
          })
        ],
        `${$projectDetails.slug}.json`,
        {
          type: 'application/json'
        }
      )

      // @ts-ignore-next-line
      await web3StorageClient.put([file], {
        name: `${$projectDetails.slug}.json`,
        maxRetries: 5
      })

      // let res = await $sessionStore.provider.getCode(deployedAddress)
      // console.log('res', res)
      // const timeout = setTimeout(async () => {
      //   res = await $sessionStore.provider.getCode(deployedAddress)
      //   console.log('res', res)
      //   showWidgetPreview = true
      //   clearTimeout(timeout)
      // }, 7000)
    } catch (error) {
      console.error(error)
      addNotification('Deployment failed', 'error')
      loading = false
    }

    clearInterval(interval)
  }

  // Copy the fund ring widget instantiation code
  const handleCopyFundringWidgetCode = async () => {
    await clipboardCopy(
      `<script src="fund-ring-widget.js"><\/script>\n\n<fund-ring-widget\n  contractAddress="${deployedAddress}"\n  title="Help fund ${$projectDetails.name}!"\n  description="A brief description"\n\/>`
    )
    addNotification('Copied to clipboard!', 'success')
  }

  // Download the fund ring widget web component
  const handleDownloadFundringWidget = async () => {
    const downloadLink = document.createElement('a')
    downloadLink.href = `${window.location.origin}/fund-ring-widget.js`
    downloadLink.download = 'fund-ring-widget.js'
    downloadLink.click()
  }

  onDestroy(() => {
    unsubscribeEvents()
  })
</script>

<h1 class="mb-12">Join the Ring</h1>

<IntroBlurb />

<!-- Project Details -->
<Step {currentStep} step={1} title="Provide Your Project Details">
  <JoinForm slot="main" {handleDetailsSubmit} />
</Step>

<!-- Sign Proof -->
<Step
  {currentStep}
  step={2}
  title="Sign A Funding Proof"
  body="Connect your fund wallet to sign a Fund Proof. We’ll use this signed message to verify the connection between the fund wallet"
  buttonLabel={connectButtonText}
  buttonAction={handleConnectOrSign}
/>

<!-- Add Proof to Repo -->
<Step
  {currentStep}
  step={3}
  title="Add The Funding Proof To Your Git Repo"
  body={`To prove the connection between your project’s code and the funding wallet, please add a file called \`${
    $projectDetails.name ? $projectDetails.slug : '<project-slug>'
  }.fundring\` to the root of your repository.`}
  buttonLabel={`Download ${
    $projectDetails.name ? $projectDetails.slug : '<project-slug>'
  }.fundring`}
  buttonAction={handleDownloadFundringFile}
/>

<!-- Verify Proof in Repo -->
<Step
  {currentStep}
  step={4}
  title="Verify Your Repo"
  body={`Once the \`${
    $projectDetails.name ? $projectDetails.slug : '<project-slug>'
  }.fundring\` file containing your funding proof has been pushed to your repository, click the button below to verify it was added correctly.`}
  buttonLabel="Verify Funding Proof"
  buttonAction={handleVerifyFundring}
/>

<!-- Deploy the contract -->
<Step
  {currentStep}
  step={5}
  title="Deploy The Contract"
  html={`<p class="mb-4">This step will:</p><ol class="pl-10 mb-4 list-decimal"><li class="mb-2"><strong>Deploy</strong> the Fund Ring contract for you</li><li class="mb-2"><strong>Initialize</strong> the funding goals you entered above</li><li class="mb-2"><strong>Announce</strong> your application to the Fund Ring network.</li></ol><p class="mb-8">Once it’s deployed, you’ll immediately be able to receive funding.</p>`}
  buttonLabel={loading
    ? loadingText[i]
    : deployedAddress
    ? 'Copy to Clipboard'
    : 'Deploy Contract'}
  buttonAction={deployedAddress
    ? async () => {
        await clipboardCopy(deployedAddress)
        addNotification('Copied to clipboard', 'success')
      }
    : handleDeployContract}
  buttonDisabled={loading}
  {loading}
>
  <div slot="main">
    {#if deployedAddress}
      <p class="mb-4">Contract deployed to:</p>
      <pre
        class="prose prose-pre prose-code mb-4 p-2.5 border border-odd-gray-500 bg-odd-yellow-100 text-body-sm break-words">
          {`\n\n${deployedAddress}\n`}
      </pre>
    {/if}
  </div>
  <div slot="footer">
    {#if deployedAddress}
      <a
        href={`https://calibration.filfox.info/en/address/${deployedAddress}`}
        target="_blank"
        rel="noreferrer"
        class="btn btn-primary w-full mt-4 text-odd-yellow-100"
      >
        View on Filfox
      </a>
    {/if}
  </div>
</Step>

<!-- Copy Widget Embed Code -->
<Step
  {currentStep}
  step={6}
  title="Embed The Funding Widget"
  body="Now that your contract is deployed, download the widget script and add it to your project then copy the code below to embed a funding widget directly into your project page."
  buttonLabel="Copy to Clipboard"
  buttonAction={handleCopyFundringWidgetCode}
>
  <div slot="main">
    {#if deployedAddress}
      {@const html = `\n<script src="fund-ring-widget.js"><\/script>\n\n<fund-ring-widget\n  contractAddress="${deployedAddress}"\n  title="Help fund ${$projectDetails.name}!"\n  description="A brief description"\n\/>`}
      <pre
        class="p-2.5 mb-4 border border-odd-gray-500 bg-odd-yellow-100 text-body-sm overflow-x-scroll">
        <code class="language-html text-left">
          {html}
        </code>
      </pre>
    {:else}
      {@const html = `\n<script src="fund-ring-widget.js"><\/script>\n\n<fund-ring-widget\n  contractAddress="<CONTRACT_ADDRESS>"\n  title="Help fund ${
        $projectDetails.name ?? '<PROJECT_NAME>'
      }!"\n  description="A brief description"\n\/>`}
      <pre
        class="p-2.5 mb-4 border border-odd-gray-500 bg-odd-yellow-100 text-body-sm overflow-x-scroll">
        <code class="language-html text-left">
          {html}
        </code>
      </pre>
    {/if}
  </div>
  <div slot="footer">
    <button
      class="btn btn-primary w-full mt-4 mb-4 text-odd-yellow-100"
      on:click={handleDownloadFundringWidget}
      disabled={currentStep !== 6}
    >
      Download widget script
    </button>

    {#if currentStep === 6}
      <!-- {#if showWidgetPreview}
        <h3 class="mb-4 uppercase text-body-sm">Widget Preview</h3>

        <FundRingWidget
          contractAddress={deployedAddress}
          title={`Help fund ${$projectDetails.name}!`}
          description="A brief description"
        />
      {/if} -->
    {/if}
  </div>
</Step>
