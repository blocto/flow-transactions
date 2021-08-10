import FlowToken from 0x7e60df042a9c0868
import FUSD from 0xe223d8a629e49c68
import FusdUsdtSwapPair from 0x3502a5dacaf350bb
import FlowSwapPair from 0xd9854329b7edf136

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