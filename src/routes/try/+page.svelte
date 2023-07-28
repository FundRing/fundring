<script lang="ts">
  import { onDestroy, onMount } from 'svelte'

  import { sessionStore } from '$src/stores'
  import Connected from './components/Connected.svelte'
  import Disconnected from './components/Disconnected.svelte'

  console.log('$sessionStore', $sessionStore)

  let connected = $sessionStore.ethereumClient.getAccount().isConnected

  const unsubscribeEvents = $sessionStore.web3modal.subscribeEvents(
    newState => {
      connected = newState.name === 'ACCOUNT_CONNECTED'
    }
  )
  const unsubscribeAccount = $sessionStore.ethereumClient.watchAccount(
    newState => {
      console.log('watchAccount', newState)
      connected = newState.isConnected
    }
  )

  onDestroy(() => {
    unsubscribeEvents()
    unsubscribeAccount()
  })
</script>

{#if connected}
  <Connected />
{:else}
  <Disconnected />
{/if}
