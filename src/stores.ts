import { writable } from 'svelte/store'
import type { Writable } from 'svelte/store'

import { loadTheme } from '$lib/theme'
import type { Notification } from '$lib/notifications'
import type { Session } from '$lib/session'
import type { Theme } from '$lib/theme'

export const themeStore: Writable<Theme> = writable(loadTheme())

export const sessionStore: Writable<Session> = writable({
  loading: true,
  ethereumClient: null,
  web3modal: null,
  provider: null
})

export const notificationStore: Writable<Notification[]> = writable([])
