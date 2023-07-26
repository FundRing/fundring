<script lang="ts">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { signMessage } from '@wagmi/core'

  import { sessionStore } from '$src/stores'
  import { addNotification } from '$lib/notifications'
  import JoinForm from '$components/forms/Join.svelte'
  import IntroBlurb from './components/IntroBlurb.svelte'

  let currentStep = 0

  const projectDetails = writable({
    name: null,
    repoLink: null,
    fundingGoal: null,
    frequency: null,
    signature: null
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
      frequency
    }))

    console.log('$projectDetails', $projectDetails)

    currentStep = 1
  }

  // Connect via WalletConnect
  let account = $sessionStore.ethereumClient.getAccount()
  $: connectButtonText = account.isConnected
    ? 'Sign Proof'
    : 'Connect Your Wallet'
  const unsubscribeEvents = $sessionStore.web3modal.subscribeEvents(
    newState => {
      connectButtonText =
        newState.name === 'ACCOUNT_CONNECTED'
          ? 'Sign Proof'
          : 'Connect Your Wallet'
    }
  )
  // Either connect the user's wallet client or sign the proof
  const handleConnectOrSign = async () => {
    try {
      account = $sessionStore.ethereumClient.getAccount()
      if (account.isConnected) {
        const signature = await signMessage({
          message: 'Create my .fundring proof'
        })
        projectDetails.update(state => ({
          ...state,
          signature
        }))
        currentStep = 2
      } else {
        await $sessionStore.web3modal.openModal({
          route: 'ConnectWallet'
        })
      }
    } catch (error) {
      console.error(error)
    }
  }

  // Download fundring file with signed proof
  const handleDownloadFundring = async () => {
    const blob = new Blob([$projectDetails.signature], { type: 'octet/stream' })
    const fileURL = URL.createObjectURL(blob)

    const downloadLink = document.createElement('a')
    downloadLink.href = fileURL
    downloadLink.download = '..fundring'
    downloadLink.click()
    URL.revokeObjectURL(fileURL)

    currentStep = 3
  }

  // Verify fundring file is in repo
  const handleVerifyFundring = async () => {
    console.log('verify fundring')
    const repoPath = $projectDetails.repoLink
      .split('github.com')[1]
      .split('.git')[0]
    const response = await fetch(
      `https://raw.githubusercontent.com${repoPath}/main/fundring`
    )
    const blob = await response.blob()
    const text = await blob.text()

    if (
      text.trim().toLowerCase() ===
      $projectDetails.signature.trim().toLowerCase()
    ) {
      addNotification('Your fundring file has been verified', 'success')
      currentStep = 4
    } else {
      addNotification('Your fundring file could not be verified', 'error')
    }
  }

  let steps = [
    {
      title: 'Provide Your Project Details',
      buttonLabel: 'Submit Details'
    },
    {
      title: 'Sign A Funding Proof',
      body:
        'Connect your fund wallet to sign a Fund Proof. We’ll use this signed message to verify the connection between the fund wallet',
      buttonLabel: account.isConnected ? 'Sign Proof' : 'Connect Your Wallet',
      buttonAction: handleConnectOrSign
    },
    {
      title: 'Add The Funding Proof To Your Git Repo',
      body:
        'To prove the connection between your project’s code and the funding wallet, please add a file called `fundring` to the root of your repository.',
      buttonLabel: 'Download fundring',
      buttonAction: handleDownloadFundring
    },
    {
      title: 'Verify Your Repo',
      body:
        'Once you the fundring file containing your funding proof has been pushed to your repository, click the button below to verify it was added correctly.',
      buttonLabel: 'Verify Funding Proof',
      buttonAction: handleVerifyFundring
    },
    {
      title: 'Deploy The Contract',
      html:
        '<p class="mb-4">This step will:</p><ol class="pl-10 mb-4 list-decimal"><li class="mb-2"><strong>Deploy</strong> the Fund Ring contract for you</li><li class="mb-2"><strong>Initialize</strong> the funding goals you entered above</li><li class="mb-2"><strong>Announce</strong> your application to the Fund Ring network.</li></ol><p class="mb-8">Once it’s deployed, you’ll immediately be able to receive funding.</p>',
      buttonLabel: 'I have deployed the contract',
      buttonAction: () => (currentStep = 5)
    },
    {
      title: 'Embed The Funding Widget',
      body:
        'Now that your contract is deployed, copy the code below to embed a funding widget directly into your project page.',
      buttonLabel: 'Copy to Clipboard'
    }
  ]

  onDestroy(() => {
    unsubscribeEvents()
  })
</script>

<h1 class="mb-12">Join the Ring</h1>

<IntroBlurb />

{#each steps as step, i}
  <div id={`step${i + 1}`} class="mb-10">
    <h3 class="uppercase text-body-sm">
      Step {i + 1}
      {#if currentStep > i}<span class="pl-2 text-odd-green-500">
          Complete!
        </span>{/if}
    </h3>
    <h2 class="mb-4">{step.title}</h2>

    {#if i === 0}
      <JoinForm {step} {handleDetailsSubmit} />
    {/if}

    {#if step.body}
      <p class="mb-8">{step.body}</p>
    {/if}

    {#if step.html}
      {@html step.html}
    {/if}

    {#if step.buttonLabel && i !== 0}
      <button
        on:click={step.buttonAction ?? (() => {})}
        disabled={currentStep < i}
        class="btn btn-primary {i === 5
          ? 'btn-outline'
          : ''} w-full text-odd-yellow-100"
      >
        {#if i === 1}
          {connectButtonText}
        {:else}
          {step.buttonLabel}
        {/if}
      </button>
    {/if}
  </div>
{/each}
