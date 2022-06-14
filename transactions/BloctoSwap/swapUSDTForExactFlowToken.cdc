import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import TeleportedTetherToken from 0xTELEPORTED_USDT_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import FlowSwapPair from 0xFLOW_USDT_SWAP_ADDRESS

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