<script lang="ts">
  import { onDestroy } from 'svelte'

  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'
  import { sessionStore } from '$src/stores'

  export let title: string = 'Help fund us!'
  export let bodyCopy: string =
    'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'

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

<div
  class="w-full pt-10 px-8 pb-6 border border-odd-gray-500 rounded-sm shadow-normal bg-odd-yellow-200 text-odd-gray-500"
>
  <h2 class="mb-2">{title}</h2>
  <p class="mb-8 text-body-sm">
    {bodyCopy}
  </p>

  <div class="mb-4" />

  <button
    on:click={handleConnect}
    class="btn h-[54px] w-full mb-7 bg-odd-gray-500 hover:bg-odd-gray-400 text-odd-yellow-100 !border-0"
  >
    {#if loading}
      <span class="loading loading-spinner text-primary" />
      processing
    {:else}
      Connect Your Wallet to Continue
    {/if}
  </button>

  <a
    class="flex items-center justify-center gap-1 font-sans text-tag text-odd-green-500 text-center"
    href="https://fundring.fission.app"
    target="_blank"
  >
    Powered by <BrandLogoSmall /> Fund Ring
  </a>
</div>
