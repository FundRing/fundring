<script lang="ts">
  import '../global.css'
  // import { addNotification } from '$lib/notifications'
  import { appDescription, appImageURL, appName, appURL } from '$lib/app-info'
  import { sessionStore, themeStore } from '../stores'
  // import { errorToMessage } from '$lib/session'
  // import { initialize } from '$lib/init'
  // import FullScreenLoadingSpinner from '$components/common/FullScreenLoadingSpinner.svelte'
  import Header from '$components/Header.svelte'
  import Notifications from '$components/notifications/Notifications.svelte'
  import SessionProvider from '$components/auth/wallet-connect/SessionProvider.svelte'

  // sessionStore.subscribe(session => {
  //   if (session.error) {
  //     const message = errorToMessage(session.error)
  //     addNotification(message, 'error')
  //   }
  // })

  // const init = async () => {
  //   await initialize()
  // }

  // init()
</script>

<svelte:head>
  <title>{appName}</title>

  <meta name="description" content={appDescription} />
  <meta property="og:title" content={appName} />
  <meta property="og:description" content={appDescription} />
  <meta property="og:url" content={appURL} />
  <meta property="og:image" content={appImageURL} />
  <meta name="twitter:title" content={appName} />
  <meta name="twitter:description" content={appDescription} />
  <meta name="twitter:image" content={appImageURL} />
  <meta name="twitter:image:alt" content={appName} />
</svelte:head>

<div
  data-theme={$themeStore.selectedTheme}
  class="min-h-screen pt-[86px] pb-10 bg-odd-yellow-200 text-odd-gray-500"
>
  <Notifications />

  <SessionProvider>
    <!-- {#if $sessionStore.loading}
      <FullScreenLoadingSpinner /> -->
    <!-- {:else} -->
    <Header />
    <div class="w-full max-w-[560px] mx-auto pt-[76px] px-10">
      <slot />
    </div>
    <!-- {/if} -->
  </SessionProvider>
</div>
