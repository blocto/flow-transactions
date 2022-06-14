import FungibleToken from 0x9a0766d93b6608b7
import TeleportedTetherToken from 0xab26e0a07d770ec1
import FlowToken from 0x7e60df042a9c0868
import FlowSwapPair from 0xd9854329b7edf136

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amountIn = FlowSwapPair.quoteSwapToken2ForExactToken1(amount: amountOut) / (1.0 - FlowSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let teleportedTetherTokenVault = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- teleportedTetherTokenVault.withdraw(amount: amountIn) as! @TeleportedTetherToken.Vault
    let token1Vault <- FlowSwapPair.swapToken2ForToken1(from: <- token0Vault)

      if signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) == nil {
    signer.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
    signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(
      /public/flowTokenReceiver,
      target: /storage/flowTokenVault
    )
    signer.link<&FlowToken.Vault{FungibleToken.Balance}>(
      /public/flowTokenBalance,
      target: /storage/flowTokenVault
    )
  }
    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    

    flowTokenVault.deposit(from: <- token1Vault)
  }
}