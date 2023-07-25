<script lang="ts">
  import { goto } from '$app/navigation'
  import BrandLogo from '$components/icons/BrandLogo.svelte'
</script>

<header class="navbar flex items-center justify-center bg-odd-green-500 p-0">
  <button class="px-4 bg-odd-yellow-200" on:click={() => goto('/')}>
    <BrandLogo />
  </button>
</header>
