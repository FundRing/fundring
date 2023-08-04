<script lang="ts">
  import { flip } from 'svelte/animate'

  import { notificationStore } from '../../stores'
  import Notification from '$components/notifications/Notification.svelte'
</script>

{#if $notificationStore.length}
  <div
    class="fixed z-max right-0 left-0 bottom-0 sm:right-4 sm:left-auto sm:bottom-2 flex flex-col justify-center"
  >
    {#each $notificationStore as notification (notification.id)}
      <div animate:flip>
        <Notification {notification} />
      </div>
    {/each}
  </div>
{/if}
