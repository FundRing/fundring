<script lang="ts">
  import {
    EthereumClient,
    w3mConnectors,
    w3mProvider
  } from '@web3modal/ethereum'
  import { Web3Modal } from '@web3modal/html'
  import { configureChains, createConfig } from '@wagmi/core'
  import { filecoin, filecoinCalibration } from '@wagmi/core/chains'

  import { sessionStore } from '$src/stores'
  import FullScreenLoadingSpinner from '$components/common/FullScreenLoadingSpinner.svelte'

  const chains = [filecoin, filecoinCalibration]
  const projectId = 'c7a37f5b7c8aa244bc4573f1d633cb60'

  const { publicClient } = configureChains(chains, [w3mProvider({ projectId })])

  const wagmiConfig = createConfig({
    autoConnect: false,
    connectors: w3mConnectors({ projectId, chains }),
    publicClient
  })
  const ethereumClient = new EthereumClient(wagmiConfig, chains)
  const web3modal = new Web3Modal({ projectId }, ethereumClient)
  web3modal.setDefaultChain(filecoinCalibration)

  let loading = true

  sessionStore.update(state => ({
    ...state,
    ethereumClient,
    web3modal
  }))

  loading = false
</script>

{#if loading}
  <FullScreenLoadingSpinner />
{:else}
  <slot />
{/if}
