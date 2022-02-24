import FungibleToken from 0xf233dcee88fe0abe
import TeleportedTetherToken from 0xcfdd90d4a00f7b5b
import BloctoToken from 0x0f9df91c9121c460
import BltUsdtSwapPair from 0xfcb06a5ae5b21a2d

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount) {
    
    

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

    assert(token1Vault.balance >= minAmountOut, message: "Output amount too small")

    bloctoTokenVault.deposit(from: <- token1Vault)
  }
}