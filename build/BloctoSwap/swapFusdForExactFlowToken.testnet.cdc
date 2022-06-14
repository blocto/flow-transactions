import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868
import FusdUsdtSwapPair from 0x3502a5dacaf350bb
import FlowSwapPair from 0xd9854329b7edf136

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amount0 = FlowSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - FlowSwapPair.getFeePercentage())
let amountIn = FusdUsdtSwapPair.quoteSwapToken1ForExactToken2(amount: amount0) / (1.0 - FusdUsdtSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- fusdVault.withdraw(amount: amountIn) as! @FUSD.Vault
    let token1Vault <- FusdUsdtSwapPair.swapToken1ForToken2(from: <- token0Vault)
let token2Vault <- FlowSwapPair.swapToken2ForToken1(from: <- token1Vault)

      if signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) == nil {
    signer.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
    signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(
      /public/flowTokenReceiver,
      target: /storage/flowTokenVault
    )
    signer.link<&FlowToken.Vault{FungibleToken.Balance}>(
      /public/flowTokenBalance,
      target: /storage/flowTokenVault
    )
  }
    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    

    flowTokenVault.deposit(from: <- token2Vault)
  }
}