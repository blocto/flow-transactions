import FungibleToken from 0xf233dcee88fe0abe
import FUSD from 0x3c5959b568896393
import BloctoToken from 0x0f9df91c9121c460
import FusdUsdtSwapPair from 0x87f3f233f34b0733
import BltUsdtSwapPair from 0xfcb06a5ae5b21a2d

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amount0 = BltUsdtSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - BltUsdtSwapPair.getFeePercentage())
let amountIn = FusdUsdtSwapPair.quoteSwapToken1ForExactToken2(amount: amount0) / (1.0 - FusdUsdtSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- fusdVault.withdraw(amount: amountIn) as! @FUSD.Vault
    let token1Vault <- FusdUsdtSwapPair.swapToken1ForToken2(from: <- token0Vault)
let token2Vault <- BltUsdtSwapPair.swapToken2ForToken1(from: <- token1Vault)

      if signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault) == nil {
    signer.save(<-BloctoToken.createEmptyVault(), to: /storage/bloctoTokenVault)
    signer.link<&BloctoToken.Vault{FungibleToken.Receiver}>(
      /public/bloctoTokenReceiver,
      target: /storage/bloctoTokenVault
    )
    signer.link<&BloctoToken.Vault{FungibleToken.Balance}>(
      /public/bloctoTokenBalance,
      target: /storage/bloctoTokenVault
    )
  }
    let bloctoTokenVault = signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    

    bloctoTokenVault.deposit(from: <- token2Vault)
  }
}