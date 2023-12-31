// import { dev } from '$app/environment'
import { ethers } from 'ethers'
import { get as getStore } from 'svelte/store'

import { abi } from '../contracts/FundRingProject.sol/FundRingProject.json'
import { sessionStore } from '../stores'

export const CONTRACT_ADDRESS = '0xA22D57E6be1aE643F00D048C26cA5d5e3E7E0354'

export const NETWORK_MAP = {
  mainnet: {
    chainId: '314',
    chainIdHex: '0x13a',
    wsProvider: 'wss://wss.node.glif.io/apigw/lotus/rpc/v1'
  },
  testnet: {
    chainId: '314159',
    chainIdHex: '0x4cb2f',
    contractAddress: CONTRACT_ADDRESS,
    wsProvider: 'wss://wss.calibration.node.glif.io/apigw/lotus/rpc/v0'
  }
}

export const initContractEvents = async () => {
  const wsProvider = new ethers.providers.WebSocketProvider(
    NETWORK_MAP.testnet.wsProvider
  )
  const paramInterface = new ethers.utils.Interface(abi)

  wsProvider.on('pending', async txHash => {
    const transaction = await wsProvider.getTransaction(txHash)

    if (
      !!transaction?.to &&
      transaction.to.toLowerCase() ===
        CONTRACT_ADDRESS.toLowerCase()
    ) {
      const decodedData = paramInterface.parseTransaction({
        data: transaction.data,
        value: transaction.value
      })

      console.log('decodedData', decodedData)
    }

  })
}

/**
 * Poll for the tx receipt
 */
export const checkStatusOfPendingTX = async (txHash: string): Promise<{ contractAddress: string }> => {
  let receipt = null
  while (receipt === null) {
    try {
      const provider = getStore(sessionStore).provider
      receipt = await provider.getTransactionReceipt(txHash)

      if (receipt === null) {
        // if (dev) {
        //   console.log('Checking for tx receipt...')
        // }
        continue
      }

      // if (dev) {
      //   console.log('Receipt fetched:', receipt)
      // }
    } catch (e) {
      console.error(e)
      break
    }
  }
  return receipt
}
