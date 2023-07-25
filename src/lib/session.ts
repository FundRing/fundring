import type * as odd from '@oddjs/odd'
import type { EthereumClient } from '@web3modal/ethereum'
import type { Web3Modal } from '@web3modal/html'

import { appName } from '$lib/app-info'

type Username = {
  full: string
  hashed: string
  trimmed: string
}

export type Session = {
  username: Username
  session: odd.Session | null
  authStrategy: odd.AuthenticationStrategy | null
  program: odd.Program
  loading: boolean
  backupCreated: boolean
  error?: SessionError
  ethereumClient: EthereumClient
  web3modal: Web3Modal
}

type SessionError = 'Insecure Context' | 'Unsupported Browser'

export const errorToMessage = (error: SessionError): string => {
  switch (error) {
    case 'Insecure Context':
      return `${appName} requires a secure context (HTTPS)`

    case 'Unsupported Browser':
      return `Your browser does not support ${appName}`
  }
}
