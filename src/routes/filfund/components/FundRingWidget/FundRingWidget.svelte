<script lang="ts">
  import { FilsnapAdapter } from 'filsnap-adapter'
  import { onDestroy, onMount } from 'svelte'

  import Connected from '$routes/filfund/components/FundRingWidget/Connected.svelte'
  import Disconnected from '$routes/filfund/components/FundRingWidget/Disconnected.svelte'

  export let contractAddress: string = null
  export let title: string = 'Help fund us!'
  export let description: string =
    'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'

  $: snapConnected = false
  $: walletConnected = false
  $: snap = null

  onMount(async () => {
    snapConnected = await FilsnapAdapter.isConnected()

    const mmAccounts = await window.ethereum.request({ method: 'eth_accounts' })
    walletConnected = !!(mmAccounts as string[]).length

    window.ethereum.on('accountsChanged', accounts => {
      walletConnected = !!(accounts as string[]).length
    })
  })

  onDestroy(async () => {
    window.ethereum.off('accountsChanged', accounts => {
      walletConnected = !!(accounts as string[]).length
    })
  })
</script>

<div class="fund-ring-widget-wrapper">
  {#if snapConnected && contractAddress && walletConnected}
    <Connected {contractAddress} {title} {description} bind:snap />
  {:else}
    <Disconnected
      {title}
      {description}
      bind:snap
      bind:snapConnected
      bind:walletConnected
    />
  {/if}
</div>
