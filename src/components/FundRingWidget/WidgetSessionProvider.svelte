<svelte:options tag="fund-ring-widget" accessors={true} />

<script lang="ts">
  import {
    EthereumClient,
    w3mConnectors,
    w3mProvider
  } from '@web3modal/ethereum'
  import { Web3Modal } from '@web3modal/html'
  import { configureChains, createConfig } from '@wagmi/core'
  import { filecoin, filecoinCalibration } from '@wagmi/core/chains'
  import { ethers } from 'ethers'

  import { sessionStore } from '$src/stores'
  import FundRingWidget from '$components/FundRingWidget/FundRingWidget.svelte'
  import FullScreenLoadingSpinner from '$components/common/FullScreenLoadingSpinner.svelte'

  export let contractAddress: string = null
  export let title: string = null
  export let bodyCopy: string = null

  const chains = [filecoin, filecoinCalibration]
  const projectId = 'c7a37f5b7c8aa244bc4573f1d633cb60'

  const { publicClient } = configureChains(chains, [w3mProvider({ projectId })])

  const wagmiConfig = createConfig({
    autoConnect: true,
    connectors: w3mConnectors({ projectId, chains }),
    publicClient
  })
  const ethereumClient = new EthereumClient(wagmiConfig, chains)
  const web3modal = new Web3Modal({ projectId }, ethereumClient)
  web3modal.setDefaultChain(filecoinCalibration)

  const provider = new ethers.providers.JsonRpcProvider(
    ethereumClient.chains[1]?.rpcUrls.default.http[0]
  )

  let loading = true

  // Set session store values if they have not been set yet
  if (
    !$sessionStore.ethereumClient &&
    !$sessionStore.web3modal &&
    !$sessionStore.provider
  ) {
    sessionStore.update(state => ({
      ...state,
      ethereumClient,
      web3modal,
      provider
    }))
  }

  loading = false
</script>

<div id="fund-ring-app">
  {#if loading}
    <FullScreenLoadingSpinner />
  {:else}
    <FundRingWidget {contractAddress} {bodyCopy} {title} />
  {/if}
</div>
