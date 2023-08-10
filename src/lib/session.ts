import type { EthereumClient } from '@web3modal/ethereum'
import type { Web3Modal } from '@web3modal/html'

export type Session = {
  loading: boolean
  ethereumClient: EthereumClient
  web3modal: Web3Modal
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  provider: any
}
