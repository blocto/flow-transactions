import FlowToken from 0x7e60df042a9c0868
import FUSD from 0xe223d8a629e49c68
import FusdUsdtSwapPair from 0x3502a5dacaf350bb
import FlowSwapPair from 0xd9854329b7edf136

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount, proxyHolder: AuthAccount) {
    let amountUsdt = FlowSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - FlowSwapPair.feePercentage)
    let amountIn = FusdUsdtSwapPair.quoteSwapToken1ForExactToken2(amount: amountUsdt)

    assert(amountIn < maxAmountIn, message: "Input amount too large")

    let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
        ?? panic("Could not borrow a reference to Vault")

    let flowUsdtSwapProxy = proxyHolder.borrow<&FlowSwapPair.SwapProxy>(from: /storage/flowUsdtSwapProxy)
        ?? panic("Could not borrow a reference to proxy holder")

    let fusdUsdtSwapProxy = proxyHolder.borrow<&FusdUsdtSwapPair.SwapProxy>(from: /storage/fusdUsdtSwapProxy)
      ?? panic("Could not borrow a reference to proxy holder")

    let token3Vault <- fusdVault.withdraw(amount: amountIn) as! @FUSD.Vault
    let token2Vault <- fusdUsdtSwapProxy.swapToken1ForToken2(from: <-token3Vault)
    let token1Vault <- flowUsdtSwapProxy.swapToken2ForToken1(from: <-token2Vault)

    let flowVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
      ?? panic("Could not borrow a reference to Vault")

    flowVault.deposit(from: <- token1Vault)
  }
}