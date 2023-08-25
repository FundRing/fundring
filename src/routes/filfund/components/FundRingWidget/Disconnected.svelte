<script lang="ts">
  import { FilsnapAdapter } from 'filsnap-adapter'
  import { onMount } from 'svelte'

  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'
  import { addNotification } from '$lib/notifications'

  export let snap = null
  export let snapConnected = null
  export let walletConnected = null
  export let title: string = 'Help fund us!'
  export let description: string =
    'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'

  let loading = false

  const checkIfFlaskIsInstalled = async () => {
    const hasFlask = await FilsnapAdapter.hasFlask()
    if (!hasFlask) {
      addNotification('Flask not installed', 'error')
      throw new Error('Flask not installed')
    }
  }

  // Prompt the user to connect their FilSnap wallet client
  const handleConnect = async () => {
    loading = true
    try {
      await checkIfFlaskIsInstalled()

      const isSnapConnected = await FilsnapAdapter.isConnected()
      if (!isSnapConnected) {
        snap = await FilsnapAdapter.connect(
          { network: 'testnet' },
          'npm:filsnap'
        )
        snapConnected = true
        addNotification('Filsnap connected successfully', 'success')
      }

      await window.ethereum.request({ method: 'eth_requestAccounts' })
      walletConnected = true
      addNotification('Wallet client connected successfully', 'success')
    } catch (error) {
      console.error(error)
      addNotification('Could not connect your Filsnap wallet client', 'error')
    }

    loading = false
  }

  onMount(async () => {
    await checkIfFlaskIsInstalled()
  })
</script>

<div
  class="w-full pt-10 px-8 pb-6 border border-odd-gray-500 rounded-sm shadow-normal bg-odd-yellow-200 text-odd-gray-500"
>
  <h2 class="mb-2">{title}</h2>
  <p class="mb-8 text-body-sm">
    {description}
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
