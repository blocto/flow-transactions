import FungibleToken from 0xf233dcee88fe0abe
import FUSD from 0x3c5959b568896393
import TeleportedTetherToken from 0xcfdd90d4a00f7b5b
import FusdUsdtSwapPair from 0x87f3f233f34b0733

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount) {
    
    

    let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- fusdVault.withdraw(amount: amountIn) as! @FUSD.Vault
    let token1Vault <- FusdUsdtSwapPair.swapToken1ForToken2(from: <- token0Vault)

      if signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) == nil {
    signer.save(<-TeleportedTetherToken.createEmptyVault(), to: TeleportedTetherToken.TokenStoragePath)
    signer.link<&TeleportedTetherToken.Vault{FungibleToken.Receiver}>(
      TeleportedTetherToken.TokenPublicReceiverPath,
      target: TeleportedTetherToken.TokenStoragePath
    )
    signer.link<&TeleportedTetherToken.Vault{FungibleToken.Balance}>(
      TeleportedTetherToken.TokenPublicBalancePath,
      target: TeleportedTetherToken.TokenStoragePath
    )
  }
    let teleportedTetherTokenVault = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) 
      ?? panic("Could not borrow a reference to Vault")

    assert(token1Vault.balance >= minAmountOut, message: "Output amount too small")

    teleportedTetherTokenVault.deposit(from: <- token1Vault)
  }
}