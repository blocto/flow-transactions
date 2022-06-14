import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import TeleportedTetherToken from 0xab26e0a07d770ec1
import FlowSwapPair from 0xd9854329b7edf136

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amountIn = FlowSwapPair.quoteSwapToken1ForExactToken2(amount: amountOut) / (1.0 - FlowSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- flowTokenVault.withdraw(amount: amountIn) as! @FlowToken.Vault
    let token1Vault <- FlowSwapPair.swapToken1ForToken2(from: <- token0Vault)

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

    

    teleportedTetherTokenVault.deposit(from: <- token1Vault)
  }
}