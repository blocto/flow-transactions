import FungibleToken from 0xf233dcee88fe0abe
import FUSD from 0x3c5959b568896393
import FlowToken from 0x1654653399040a61
import FusdUsdtSwapPair from 0x87f3f233f34b0733
import FlowSwapPair from 0xc6c77b9f5c7a378f

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