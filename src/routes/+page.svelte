<script lang="ts">
  const paragraphs = [
    {
      title: 'Do you run a FLOSS project?',
      body:
        'Fund Ring is a smart contract standard and set of ready-to-embed components, designed to simplify the process of receiving funding for your project in FIL.'
    },
    {
      title: 'Get a little help from your friends',
      body:
        'When you join Fund Ring, you join a broad community of FLOSS projects. It’s like a good ol’ fashioned web ring for funding.'
    },
    {
      title: 'Help shine a light on projects that matter',
      body:
        'You have full control over how you connect to the Fund Ring. You can use it to highlight other projects you run or rely on.'
    },
    {
      title: 'Simple to setup',
      body:
        'All you need is a git repo and a Filecoin wallet. Our wizard will guide you through the quick setup process.'
    }
  ]
</script>

<h1 class="mb-10">Get funded in FIL</h1>

{#each paragraphs as paragraph}
  <div class="mb-10">
    <h2 class="mb-4">{paragraph.title}</h2>
    <p>{paragraph.body}</p>
  </div>
{/each}

<a href="/fund" class="btn btn-outline btn-primary w-full mb-4">
  Fund the Ring
</a>
<!-- <a href="/join" class="btn btn-outline btn-primary w-full mb-4">
  Who’s using Fund Ring?
</a> -->
<a href="/join" class="btn btn-primary w-full text-odd-yellow-100">
  Join the Ring
</a>
