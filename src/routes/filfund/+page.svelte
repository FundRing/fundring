<script lang="ts">
  import { CONTRACT_ADDRESS } from '$lib/contract'
  import FundRingWidget from '$routes/filfund/components/FundRingWidget/FundRingWidget.svelte'
</script>

<h1 class="mb-12">Fund the Ring with Native FIL</h1>

<FundRingWidget contractAddress={CONTRACT_ADDRESS} />
