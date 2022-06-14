import FungibleToken from 0x9a0766d93b6608b7
import BloctoToken from 0x6e0797ac987005f5
import FUSD from 0xe223d8a629e49c68
import BltUsdtSwapPair from 0xc59604d4e65f14b3
import FusdUsdtSwapPair from 0x3502a5dacaf350bb

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amount0 = FusdUsdtSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - FusdUsdtSwapPair.getFeePercentage())
let amountIn = BltUsdtSwapPair.quoteSwapToken1ForExactToken2(amount: amount0) / (1.0 - BltUsdtSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let bloctoTokenVault = signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- bloctoTokenVault.withdraw(amount: amountIn) as! @BloctoToken.Vault
    let token1Vault <- BltUsdtSwapPair.swapToken1ForToken2(from: <- token0Vault)
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