<script lang="ts">
  export let currentStep = 0
  export let step = 0
  export let title = null
  export let body = null
  export let html = null
  export let buttonLabel = null
  export let buttonAction = null
  export let buttonDisabled = false
  export let loading = false
</script>

<div id={`step${step}`} class={step !== 1 ? 'pt-10' : ''}>
  <h3 class="uppercase text-body-sm">
    Step {step}
    {#if currentStep > step}<span class="pl-2 text-odd-green-500">
        Complete!
      </span>{/if}
  </h3>
  <h2 class="mb-4">{title}</h2>

  {#if body}
    <p class="mb-8">{body}</p>
  {/if}

  {#if html}
    {@html html}
  {/if}

  <slot name="main" />

  {#if buttonLabel && step !== 1}
    <button
      on:click={buttonAction}
      disabled={currentStep < step || buttonDisabled || loading}
      class="btn btn-primary {step === 6 || step === 5
        ? 'btn-outline'
        : ''} w-full text-odd-yellow-100"
    >
      {#if loading}
        <span class="loading loading-spinner text-primary" />
      {/if}
      {buttonLabel}
    </button>
  {/if}

  <slot name="footer" />
</div>
