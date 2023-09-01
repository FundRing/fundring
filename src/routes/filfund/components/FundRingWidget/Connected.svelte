<script lang="ts">
  import { utils } from 'ethers'
  import { FilsnapAdapter } from 'filsnap-adapter'
  import { RPC } from 'iso-filecoin/rpc'
  import { Token } from 'iso-filecoin/token'
  import { onMount } from 'svelte'

  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'
  import { addNotification } from '$lib/notifications'
  import { NETWORK_MAP } from '$lib/contract'

  export let snap = null
  export let title: string = 'Help fund us!'
  export let description: string =
    'If you rely upon Fund Ring’s efforts to keep your project going, please consider supporting our funding goal. Every little bit helps.'

  let fetchingData = false
  let loading = false
  let totalFundsRaised = 0

  const FUNDRING_CONTRACT_OWNER_ADDRESS =
    't410ftgo7vbcywlxf72blsnr4tgmpvcxrs6icg34pouq'
  const LOADING_TEXT = ['processing', 'sit tight', 'network speed may vary']
  const RPC_ENDPOINT = 'https://api.calibration.node.glif.io/rpc/v1'

  const rpc = new RPC({
    api: RPC_ENDPOINT,
    network: 'testnet'
  })

  // Get the total funds sent to the FundRing wallet so far
  const getTotalFundsRaised = async () => {
    fetchingData = true
    try {
      const balance = await rpc.balance(FUNDRING_CONTRACT_OWNER_ADDRESS)

      totalFundsRaised = Number(
        Number(utils.formatEther(balance.result)).toFixed(2)
      )
    } catch (error) {
      console.error(error)
      addNotification('Failed to fetch balance', 'error')
    }
    fetchingData = false
  }

  // Submit the users FIL contribution to the Fund Ring wallet
  let i = 0
  const handleContributeSubmit = async (event: SubmitEvent) => {
    loading = true

    const interval = setInterval(() => {
      i == 2 ? (i = 0) : i++
    }, 1400)

    try {
      const formData = new FormData(event.target as HTMLFormElement)
      const contributionAmount = String(formData.get('contribution_amount'))

      // Prompt the user to switch networks if they are not on Calibration
      if (
        window.ethereum.chainId.toLowerCase() !==
        NETWORK_MAP.testnet.chainId.toLowerCase()
      ) {
        try {
          await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: NETWORK_MAP.testnet.chainIdHex }]
          })
        } catch (error) {
          console.error(error)
          console.log('could not programmitcally switch network')
        }
      }

      const signedMessage = await snap.signMessage({
        to: FUNDRING_CONTRACT_OWNER_ADDRESS,
        value: Token.fromFIL(contributionAmount).toAttoFIL().toString()
      })

      const send = await snap.sendMessage(signedMessage.result)

      const txComplete = await rpc.call('Filecoin.MpoolPending', [
        {
          '/': send.result.cid
        }
      ])

      console.log('txComplete', txComplete)

      await getTotalFundsRaised()

      loading = false
    } catch (error) {
      console.error(error)
      addNotification('Transaction failed', 'error')
      loading = false
    }
    clearInterval(interval)
  }

  onMount(async () => {
    fetchingData = true
    loading = true

    snap = await FilsnapAdapter.connect(
      { network: 'testnet' },
      'npm:filsnap',
      '*'
    )

    await getTotalFundsRaised()

    fetchingData = false
    loading = false
  })
</script>

<div
  class="w-full pt-10 px-8 pb-6 border border-odd-gray-500 rounded-sm shadow-normal bg-odd-yellow-200 text-odd-gray-500"
>
  <h2 class="mb-2">{title}</h2>
  <p class="mb-8 text-body-sm">
    {description}
  </p>

  <h3 class="mb-1">How much can you help?</h3>
  <p class="mb-4 text-body-sm">
    We have received {#if fetchingData}<div
        class="inline-block w-5 h-4 ml-1 translate-y-[2px] bg-odd-gray-100 rounded-sm animate-pulse"
      />{:else}{totalFundsRaised}{/if}FIL so far.
  </p>

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
      class="btn form-btn h-[54px] w-full bg-odd-gray-500 hover:bg-odd-gray-400 text-odd-yellow-100 !border-0"
    >
      {#if loading}
        <span class="loading loading-spinner" />
        {LOADING_TEXT[i]}
      {:else}
        Contribute FIL
      {/if}
    </button>
  </form>

  <a
    class="flex items-center justify-center gap-1 font-sans text-tag text-odd-green-500 text-center"
    href="https://fundring.fission.app"
    target="_blank"
  >
    Powered by <BrandLogoSmall /> Fund Ring
  </a>
</div>
