<script lang="ts">
  import { onDestroy } from 'svelte'

  import { sessionStore } from '$src/stores'
  import Connected from '$components/FundRingWidget/Connected.svelte'
  import Disconnected from '$components/FundRingWidget/Disconnected.svelte'

  export let contractAddress: string = null
  export let title: string = 'Help fund us!'
  export let description: string =
    'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'

  let connected = $sessionStore.ethereumClient.getAccount().isConnected

  const unsubscribeEvents = $sessionStore.web3modal.subscribeEvents(
    newState => {
      connected = newState.name === 'ACCOUNT_CONNECTED'
    }
  )

  const unsubscribeAccount = $sessionStore.ethereumClient.watchAccount(
    newState => {
      connected = newState.isConnected
    }
  )

  onDestroy(() => {
    unsubscribeEvents()
    unsubscribeAccount()
  })
</script>

<div class="fund-ring-widget-wrapper">
  {#if connected && contractAddress}
    <Connected {contractAddress} {title} {description} />
  {:else}
    <Disconnected {title} {description} />
  {/if}
</div>
