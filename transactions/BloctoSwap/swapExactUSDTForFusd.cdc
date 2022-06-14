import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import TeleportedTetherToken from 0xTELEPORTED_USDT_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import FusdUsdtSwapPair from 0xFUSD_USDT_SWAP_ADDRESS

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