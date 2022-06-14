import FungibleToken from 0x9a0766d93b6608b7
import TeleportedTetherToken from 0xab26e0a07d770ec1
import BloctoToken from 0x6e0797ac987005f5
import BltUsdtSwapPair from 0xc59604d4e65f14b3

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amountIn = BltUsdtSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - BltUsdtSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let teleportedTetherTokenVault = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- teleportedTetherTokenVault.withdraw(amount: amountIn) as! @TeleportedTetherToken.Vault
    let token1Vault <- BltUsdtSwapPair.swapToken2ForToken1(from: <- token0Vault)

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

    

    bloctoTokenVault.deposit(from: <- token1Vault)
  }
}