<!-- <svelte:options tag="funding-widget" /> -->
<script lang="ts">
  import {
    getNetwork,
    prepareWriteContract,
    switchNetwork,
    watchContractEvent,
    writeContract
  } from '@wagmi/core'
  import { dev } from '$app/environment'
  import { ethers, utils } from 'ethers'
  import { onDestroy, onMount } from 'svelte'
  import { parseEther } from 'viem'

  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'
  import { abi } from '$contracts/FundRingProject.sol/FundRingProject.json'
  import { sessionStore } from '$src/stores'
  import { addNotification } from '$lib/notifications'
  import {
    CONTRACT_ADDRESS,
    NETWORK_MAP,
    checkStatusOfPendingTX
  } from '../lib/contract'

  const contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    abi,
    $sessionStore.provider
  )

  let loading = false
  let fetchingData = true
  let fundingGoal = 0
  let totalFundsRaised = 0

  // Submit the users FIL contribution to the Fund Ring contract
  const handleContributeSubmit = async (event: SubmitEvent) => {
    loading = true

    try {
      const formData = new FormData(event.target as HTMLFormElement)
      const contributionAmount = String(formData.get('contribution_amount'))
      const { chain } = getNetwork()

      // Prompt the user to switch networks if they are not on Calibration
      if (chain.id !== Number(NETWORK_MAP.testnet.chainId)) {
        try {
          const network = await switchNetwork({
            chainId: Number(NETWORK_MAP.testnet.chainId)
          })
          console.log('network', network)
        } catch (error) {
          console.error(error)
          console.log('could not programmitcally switch network')
        }
      }

      const request = await prepareWriteContract({
        address: CONTRACT_ADDRESS,
        abi,
        functionName: 'contributeFunds',
        value: parseEther(contributionAmount)
      })
      const { hash } = await writeContract(request)

      await checkStatusOfPendingTX(hash)

      const totalFundsRaisedRaw = await contract.getTotalFundsRaised()
      totalFundsRaised = Number(ethers.utils.formatEther(totalFundsRaisedRaw))

      loading = false
    } catch (error) {
      console.error(error)
      addNotification('Transaction failed', 'error')
      loading = false
    }
  }

  // Listen for contribution events on contract and update amounts if there is network latency
  contract.on('FundRingFundsContributed', (_p1, _p2, _totalFundsRaised) => {
    if (
      Number(ethers.utils.formatEther(_totalFundsRaised)) > totalFundsRaised
    ) {
      fetchingData = true
      totalFundsRaised = Number(ethers.utils.formatEther(_totalFundsRaised))
      fetchingData = false
    }
  })

  onMount(async () => {
    fetchingData = true

    const totalFundsRaisedRaw = await contract.getTotalFundsRaised()
    totalFundsRaised = Number(ethers.utils.formatEther(totalFundsRaisedRaw))
    const fundingGoalRaw = await contract.fundingGoal()
    fundingGoal = Number(ethers.utils.formatEther(fundingGoalRaw))

    fetchingData = false
  })

  onDestroy(async () => {
    // Stop listening for events on contract
    contract.off('FundRingFundsContributed', () => {
      if (dev) {
        console.log('unsubscribed from contract events')
      }
    })
  })
</script>

<h1 class="mb-12">Fund the Ring</h1>

<div
  class="w-full pt-10 px-8 pb-6 mb-10 border border-odd-gray-500 rounded-sm shadow-normal"
>
  <h2 class="mb-2">Help fund us!</h2>
  <p class="mb-8 text-body-sm">
    If you rely upon Fund Ring’s efforts to keep your project going, please
    consider supporting our funding goal. Every little bit helps.
  </p>

  <h3 class="mb-1">How much can you help?</h3>
  <p class="mb-4 text-body-sm">
    Our goal this month is {#if fetchingData}<div
        class="inline-block w-5 h-4 ml-1 translate-y-[2px] bg-odd-gray-100 rounded-sm animate-pulse"
      />{:else}{fundingGoal}{/if}FIL. We need another {#if fetchingData}<div
        class="inline-block w-5 h-4 ml-1 translate-y-[2px] bg-odd-gray-100 rounded-sm animate-pulse"
      />{:else}{fundingGoal - totalFundsRaised}{/if}FIL to hit it.
  </p>

  <div class="mb-4" />

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
      class="btn form-btn h-[54px] w-full bg-odd-gray-500 text-odd-yellow-100"
    >
      {#if loading}
        <span class="loading loading-spinner text-primary" />
        processing
      {:else}
        Contribute FIL
      {/if}
    </button>
  </form>

  <p
    class="flex items-center justify-center gap-1 font-sans text-tag text-odd-green-500 text-center"
  >
    Powered by <BrandLogoSmall /> Fund Ring
  </p>
</div>

<a href="/join" class="btn btn-primary w-full text-odd-yellow-100">
  Join the Ring
</a>
