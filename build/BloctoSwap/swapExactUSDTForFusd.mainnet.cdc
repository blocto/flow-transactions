import FungibleToken from 0xf233dcee88fe0abe
import TeleportedTetherToken from 0xcfdd90d4a00f7b5b
import FUSD from 0x3c5959b568896393
import FusdUsdtSwapPair from 0x87f3f233f34b0733

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount) {
    
    

    let teleportedTetherTokenVault = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- teleportedTetherTokenVault.withdraw(amount: amountIn) as! @TeleportedTetherToken.Vault
    let token1Vault <- FusdUsdtSwapPair.swapToken2ForToken1(from: <- token0Vault)

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

    assert(token1Vault.balance >= minAmountOut, message: "Output amount too small")

    fusdVault.deposit(from: <- token1Vault)
  }
}