<script lang="ts">
  import { onDestroy } from 'svelte'

  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'
  import { sessionStore } from '$src/stores'

  let loading = false

  const unsubscribeModal = $sessionStore.web3modal.subscribeModal(newState => {
    loading = newState.open
  })

  // Prompt the user to connect their wallet
  const handleConnect = async () => {
    loading = true

    const account = $sessionStore.ethereumClient.getAccount()
    if (!account.isConnected) {
      await $sessionStore.web3modal.openModal({
        route: 'ConnectWallet'
      })
    }

    loading = false
  }

  onDestroy(() => {
    unsubscribeModal()
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

  <div class="mb-4" />

  <button
    on:click={handleConnect}
    class="btn h-[54px] w-full mb-7 bg-odd-gray-500 text-odd-yellow-100"
  >
    {#if loading}
      <span class="loading loading-spinner text-primary" />
      processing
    {:else}
      Connect Your Wallet to Continue
    {/if}
  </button>

  <p
    class="flex items-center justify-center gap-1 font-sans text-tag text-odd-green-500 text-center"
  >
    Powered by <BrandLogoSmall /> Fund Ring
  </p>
</div>

<a href="/join" class="btn btn-primary w-full text-odd-yellow-100">
  Join the Ring
</a>
