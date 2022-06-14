import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import TeleportedTetherToken from 0xTELEPORTED_USDT_ADDRESS
import FusdUsdtSwapPair from 0xFUSD_USDT_SWAP_ADDRESS

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