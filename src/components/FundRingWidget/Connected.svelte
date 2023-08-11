<script lang="ts">
  import {
    getNetwork,
    prepareWriteContract,
    switchNetwork,
    writeContract
  } from '@wagmi/core'
  import { ethers } from 'ethers'
  import { onDestroy, onMount } from 'svelte'
  import { parseEther } from 'viem'

  import BrandLogoSmall from '../icons/BrandLogoSmall.svelte'
  import { abi } from '../../contracts/FundRingProject.sol/FundRingProject.json'
  import { sessionStore } from '../../stores'
  import { addNotification } from '../../lib/notifications'
  import { NETWORK_MAP, checkStatusOfPendingTX } from '../../lib/contract'

  export let contractAddress: string = null
  export let title: string = 'Help fund us!'
  export let bodyCopy: string =
    'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'

  const contract = new ethers.Contract(
    contractAddress,
    abi,
    $sessionStore.provider
  )

  let loading = false
  let fetchingData = true
  let fundingFrequency = null
  let fundingGoal = 0
  let totalFundsRaised = 0
  const loadingText = ['processing', 'sit tight', 'network speed may vary']

  const FREQUENCY_MAP = {
    'one-time': '',
    monthly: ' month',
    annually: ' year'
  }

  // Get the total funds raised based on the frequency set for the contract
  const getTotalFundsRaisedByFrequency = async () => {
    let totalFundsRaisedRaw: string
    if (fundingFrequency === 'monthly') {
      totalFundsRaisedRaw = await contract.getFundsRaisedByMonth(
        new Date(Date.now())
          .toLocaleString('en-US', { month: 'long' })
          .toLowerCase()
      )
    } else if (fundingFrequency === 'annually') {
      totalFundsRaisedRaw = await contract.getFundsRaisedByYear(
        new Date().getFullYear()
      )
    } else {
      totalFundsRaisedRaw = await contract.getTotalFundsRaised()
    }
    totalFundsRaised = Number(ethers.utils.formatEther(totalFundsRaisedRaw))
  }

  // Submit the users FIL contribution to the Fund Ring contract
  let i = 0
  const handleContributeSubmit = async (event: SubmitEvent) => {
    loading = true

    const interval = setInterval(() => {
      i == 2 ? (i = 0) : i++
    }, 1400)

    try {
      const formData = new FormData(event.target as HTMLFormElement)
      const contributionAmount = String(formData.get('contribution_amount'))
      const { chain } = getNetwork()

      // Prompt the user to switch networks if they are not on Calibration
      if (chain.id !== Number(NETWORK_MAP.testnet.chainId)) {
        try {
          await switchNetwork({
            chainId: Number(NETWORK_MAP.testnet.chainId)
          })
        } catch (error) {
          console.error(error)
          console.log('could not programmitcally switch network')
        }
      }

      const request = await prepareWriteContract({
        address: contractAddress,
        abi,
        functionName: 'contributeFunds',
        value: parseEther(contributionAmount)
      })
      const { hash } = await writeContract(request)

      await checkStatusOfPendingTX(hash)

      await getTotalFundsRaisedByFrequency()

      loading = false
    } catch (error) {
      console.error(error)
      addNotification('Transaction failed', 'error')
      loading = false
    }
    clearInterval(interval)
  }

  // Listen for contribution events on contract and update amounts if there is network latency
  contract.on('FundRingFundsContributed', (_p1, _p2, _totalFundsRaised) => {
    if (
      Number(ethers.utils.formatEther(_totalFundsRaised)) > totalFundsRaised
    ) {
      fetchingData = true
      loading = true
      totalFundsRaised = Number(ethers.utils.formatEther(_totalFundsRaised))
      addNotification('Contribution successful!', 'success')
      loading = false
      fetchingData = false
    }
  })

  onMount(async () => {
    fetchingData = true

    fundingFrequency = await contract.getFundingFrequency()
    await getTotalFundsRaisedByFrequency()
    const fundingGoalRaw = await contract.fundingGoal()
    fundingGoal = Number(ethers.utils.formatEther(fundingGoalRaw))

    fetchingData = false
  })

  onDestroy(async () => {
    // Stop listening for events on contract
    contract.off('FundRingFundsContributed', () => {
      // console.log('unsubscribed from contract events')
    })
  })
</script>

<div
  class="w-full pt-10 px-8 pb-6 border border-odd-gray-500 rounded-sm shadow-normal bg-odd-yellow-200 text-odd-gray-500"
>
  <h2 class="mb-2">{title}</h2>
  <p class="mb-8 text-body-sm">
    {bodyCopy}
  </p>

  <h3 class="mb-1">How much can you help?</h3>
  <p class="mb-4 text-body-sm">
    Our goal this{FREQUENCY_MAP[fundingFrequency]} is {#if fetchingData}<div
        class="inline-block w-5 h-4 ml-1 translate-y-[2px] bg-odd-gray-100 rounded-sm animate-pulse"
      />{:else}{fundingGoal}{/if}FIL. We need another {#if fetchingData}<div
        class="inline-block w-5 h-4 ml-1 translate-y-[2px] bg-odd-gray-100 rounded-sm animate-pulse"
      />{:else}{fundingGoal - totalFundsRaised}{/if}FIL to hit it.
  </p>

  <div
    class="relative h-4 mb-4 border border-odd-gray-500 rounded overflow-hidden"
  >
    <div
      class="absolute left-0 top-0 bottom-0 z-0 h-4 bg-odd-gray-500"
      style={`width: ${(totalFundsRaised / fundingGoal) * 100}%;`}
    />
  </div>

  <form on:submit|preventDefault={handleContributeSubmit} class="mb-7">
    <div class="relative mb-4">
      <input
        id="contribution_amount"
        type="number"
        min="0"
        name="contribution_amount"
        class="h-[54px] w-full pl-2.5 pr-10 relative z-10 rounded-sm font-light text-body-sm border-odd-gray-500 border focus-visible:outline focus-visible:outline-odd-gray-500 focus-visible:border-odd-gray-500"
        required
      />
      <span
        class="absolute z-20 top-1/2 right-2.5 -translate-y-1/2 text-body-sm"
      >
        FIL
      </span>
    </div>

    <button
      disabled={loading}
      type="submit"
      class="btn form-btn h-[54px] w-full bg-odd-gray-500 hover:bg-odd-gray-400 text-odd-yellow-100 !border-0"
    >
      {#if loading}
        <span class="loading loading-spinner" />
        {loadingText[i]}
      {:else}
        Contribute FIL
      {/if}
    </button>
  </form>

  <a
    class="flex items-center justify-center gap-1 font-sans text-tag text-odd-green-500 text-center"
    href="https://fundring.fission.app"
    target="_blank"
  >
    Powered by <BrandLogoSmall /> Fund Ring
  </a>
</div>
