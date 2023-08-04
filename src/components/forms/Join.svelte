<script lang="ts">
  export let handleDetailsSubmit = event => {}

  // Ensure the repo link is a valid git link
  const handleValidateRepoLink = event => {
    const repoLink = event.target.value
    const urlPattern = new RegExp(
      '(?:https?)://(w+:?w*)?(S+)(:d+)?(/|/([w#!:.?+=&%!-/]))?'
    )

    if (
      repoLink.length > 0 &&
      !repoLink.includes('.git') &&
      !urlPattern.test(repoLink)
    ) {
      console.log('invalid')
    } else {
    }
  }
</script>

<form on:submit|preventDefault={handleDetailsSubmit}>
  <div class="flex flex-col mb-6">
    <label for="project_name" class="font-sans">Project Name</label>
    <input
      id="project_name"
      type="text"
      name="project_name"
      class="h-[46px] px-2.5 font-light text-body-sm border-odd-gray-500 border focus-visible:outline focus-visible:outline-odd-gray-500 focus-visible:border-odd-gray-500"
      required
    />
  </div>
  <div class="flex flex-col mb-6">
    <label for="repo_link" class="font-sans">
      Link to Repository (ending in .git)
    </label>
    <input
      id="repo_link"
      type="url"
      name="repo_link"
      class="h-[46px] px-2.5 font-light text-body-sm border-odd-gray-500 border focus-visible:outline focus-visible:outline-odd-gray-500 focus-visible:border-odd-gray-500"
      required
      on:input={handleValidateRepoLink}
    />
  </div>
  <div class="flex flex-col mb-6">
    <label for="funding_goal" class="font-sans">
      Funding Goal (denominated in FIL)
    </label>
    <input
      id="funding_goal"
      type="number"
      min="0"
      name="funding_goal"
      class="h-[46px] px-2.5 font-light text-body-sm border-odd-gray-500 border focus-visible:outline focus-visible:outline-odd-gray-500 focus-visible:border-odd-gray-500"
      required
    />
  </div>
  <div class="flex flex-col sm:flex-row sm:gap-4 mb-6">
    <div class="form-control">
      <label
        class="label cursor-pointer items-start sm:items-center justify-start sm:justify-center gap-2"
      >
        <input
          type="radio"
          name="frequency"
          class="radio bg-odd-yellow-100"
          checked
          value="one-time"
        />
        <span class="label-text text-body-sm">One-time</span>
      </label>
    </div>
    <div class="form-control">
      <label
        class="label cursor-pointer items-start sm:items-center justify-start sm:justify-center gap-2"
      >
        <input
          type="radio"
          name="frequency"
          class="radio bg-odd-yellow-100"
          value="monthly"
        />
        <span class="label-text text-body-sm">Monthly</span>
      </label>
    </div>
    <div class="form-control">
      <label
        class="label cursor-pointer items-start sm:items-center justify-start sm:justify-center gap-2"
      >
        <input
          type="radio"
          name="frequency"
          class="radio bg-odd-yellow-100"
          value="annually"
        />
        <span class="label-text text-body-sm">Annually</span>
      </label>
    </div>
  </div>
  <button type="submit" class="btn btn-primary w-full text-odd-yellow-100">
    Submit Details
  </button>
</form>
