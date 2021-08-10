import FlowToken from 0x1654653399040a61
import FUSD from 0x3c5959b568896393
import FusdUsdtSwapPair from 0x87f3f233f34b0733
import FlowSwapPair from 0xc6c77b9f5c7a378f

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