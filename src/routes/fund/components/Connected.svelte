<script lang="ts">
  import {
    // getContract,
    prepareWriteContract,
    // readContract,
    writeContract
  } from '@wagmi/core'
  import { ethers } from 'ethers'
  import { onMount } from 'svelte'
  import { parseEther } from 'viem'

  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'
  import { abi } from '$contracts/FundRingProject.sol/FundRingProject.json'
  import { sessionStore } from '$src/stores'
  import { addNotification } from '$lib/notifications'
  import { CONTRACT_ADDRESS, checkStatusOfPendingTX } from '../lib/contract'

  const contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    abi,
    $sessionStore.provider
  )

  let loading = false
  let fetchingData = true
  let fundingGoal = 0
  let totalFundsRaised = 0

  // Fetch current contract data
  const fetchContractData = async () => {
    fetchingData = true

    const totalFundsRaisedRaw = await contract.getTotalFundsRaised()
    totalFundsRaised = Number(ethers.utils.formatEther(totalFundsRaisedRaw))
    const fundingGoalRaw = await contract.fundingGoal()
    fundingGoal = Number(ethers.utils.formatEther(fundingGoalRaw))

    fetchingData = false
  }

  // Submit the users FIL contribution to the Fund Ring contract
  const handleContributeSubmit = async (event: SubmitEvent) => {
    loading = true

    try {
      const formData = new FormData(event.target as HTMLFormElement)
      const contributionAmount = String(formData.get('contribution_amount'))

      const request = await prepareWriteContract({
        address: CONTRACT_ADDRESS,
        abi,
        functionName: 'contributeFunds',
        value: parseEther(contributionAmount)
      })
      const { hash } = await writeContract(request)

      await checkStatusOfPendingTX(hash)

      // Contract state seems to need some extra time to after receipt is fetched(will investigate further)
      setTimeout(async () => {
        await fetchContractData()
        loading = false
      }, 10000)
    } catch (error) {
      console.error(error)
      addNotification('Transaction failed', 'error')
      loading = false
    }
  }

  onMount(async () => {
    await fetchContractData()
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

  {#if fetchingData}
    <h3 class="mb-1">Fetching current stats...</h3>
  {:else}
    <h3 class="mb-1">How much can you help?</h3>
    <p class="mb-4 text-body-sm">
      Our goal this month is {fundingGoal}FIL. We need another {fundingGoal -
        totalFundsRaised}FIL to hit it.
    </p>
  {/if}

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
