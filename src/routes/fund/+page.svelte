<script lang="ts">
  import { CONTRACT_ADDRESS } from '$lib/contract'
  import FundRingWidget from '$components/FundRingWidget/FundRingWidget.svelte'
</script>

<h1 class="mb-12">Fund the Ring</h1>

<FundRingWidget contractAddress={CONTRACT_ADDRESS} />

<a href="/join" class="btn btn-primary w-full mt-10 text-odd-yellow-100">
  Join the Ring
</a>
