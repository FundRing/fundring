<script lang="ts">
  import BrandLogoSmall from '$components/icons/BrandLogoSmall.svelte'

  // Submit the users FIL contribution to the Fund contract
  const handleContributeSubmit = async event => {
    const formData = new FormData(event.target)
    const contributionAmount = formData.get('contribution_amount')

    console.log('contributionAmount', contributionAmount)
  }
</script>

<h1 class="mb-12">Try it Out</h1>

<div
  class="w-full pt-10 px-8 pb-6 mb-10 border border-odd-gray-500 rounded-sm shadow-normal"
>
  <h2 class="mb-2">Help fund us!</h2>
  <p class="mb-8 text-body-sm">
    If you rely upon Fund Ring’s efforts to keep your project going, please
    consider supporting our funding goal. Every little bit helps.
  </p>

  <h3 class="mb-1">How much can you help?</h3>
  <p class="mb-4 text-body-sm">
    Our goal this month is 300FIL. We need another 146FIL to hit it.
  </p>

  <div class="mb-4" />

  <form on:submit|preventDefault={handleContributeSubmit} class="mb-7">
    <div class="relative mb-4">
      <input
        id="contribution_amount"
        type="number"
        min="0"
        name="contribution_amount"
        class="h-[54px] w-full px-2.5 relative z-10 rounded-sm font-light text-body-sm border-odd-gray-500 border focus-visible:outline focus-visible:outline-odd-gray-500 focus-visible:border-odd-gray-500"
        required
      />
      <span
        class="absolute z-20 top-1/2 right-2.5 -translate-y-1/2 text-body-sm"
      >
        FIL
      </span>
    </div>

    <button
      type="submit"
      class="btn h-[54px] w-full bg-odd-gray-500 text-odd-yellow-100"
    >
      Contribute FIL
    </button>
  </form>

  <p
    class="flex items-center justify-center gap-1 font-sans text-tag text-odd-green-500 text-center"
  >
    Powered by <BrandLogoSmall /> Fund Ring
  </p>
</div>

<a href="/join" class="btn btn-primary w-full text-odd-yellow-100">
  Join the Ring
</a>
