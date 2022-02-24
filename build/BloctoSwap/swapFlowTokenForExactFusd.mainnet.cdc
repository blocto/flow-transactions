import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
import FUSD from 0x3c5959b568896393
import FlowSwapPair from 0xc6c77b9f5c7a378f
import FusdUsdtSwapPair from 0x87f3f233f34b0733

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amount0 = FusdUsdtSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - FusdUsdtSwapPair.getFeePercentage())
let amountIn = FlowSwapPair.quoteSwapToken1ForExactToken2(amount: amount0) / (1.0 - FlowSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- flowTokenVault.withdraw(amount: amountIn) as! @FlowToken.Vault
    let token1Vault <- FlowSwapPair.swapToken1ForToken2(from: <- token0Vault)
let token2Vault <- FusdUsdtSwapPair.swapToken2ForToken1(from: <- token1Vault)

      if signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil {
    signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
    signer.link<&FUSD.Vault{FungibleToken.Receiver}>(
      /public/fusdReceiver,
      target: /storage/fusdVault
    )
    signer.link<&FUSD.Vault{FungibleToken.Balance}>(
      /public/fusdBalance,
      target: /storage/fusdVault
    )
  }
    let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) 
      ?? panic("Could not borrow a reference to Vault")

    

    fusdVault.deposit(from: <- token2Vault)
  }
}