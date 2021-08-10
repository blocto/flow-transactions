import FlowToken from 0xFLOW_TOKEN_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import FusdUsdtSwapPair from 0xFUSD_USDT_SWAP_ADDRESS
import FlowSwapPair from 0xFLOW_USDT_SWAP_ADDRESS

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount, proxyHolder: AuthAccount) {
    let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
      ?? panic("Could not borrow a reference to Vault")

    let fusdUsdtSwapProxy = proxyHolder.borrow<&FusdUsdtSwapPair.SwapProxy>(from: /storage/fusdUsdtSwapProxy)
      ?? panic("Could not borrow a reference to proxy holder")

    let flowUsdtSwapProxy = proxyHolder.borrow<&FlowSwapPair.SwapProxy>(from: /storage/flowUsdtSwapProxy)
      ?? panic("Could not borrow a reference to proxy holder")

    let token3Vault <- fusdVault.withdraw(amount: amountIn) as! @FUSD.Vault
    let token2Vault <- fusdUsdtSwapProxy.swapToken1ForToken2(from: <-token3Vault)
    let token1Vault <- flowUsdtSwapProxy.swapToken2ForToken1(from: <-token2Vault)

    assert(token1Vault.balance > minAmountOut, message: "Output amount too small")

    let flowVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
      ?? panic("Could not borrow a reference to Vault")

    flowVault.deposit(from: <- token1Vault)
  }
}