import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import FUSD from 0xe223d8a629e49c68
import FlowSwapPair from 0xd9854329b7edf136
import FusdUsdtSwapPair from 0x3502a5dacaf350bb

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount) {
    
    

    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- flowTokenVault.withdraw(amount: amountIn) as! @FlowToken.Vault
    let token1Vault <- FlowSwapPair.swapToken1ForToken2(from: <- token0Vault)
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

    assert(token2Vault.balance >= minAmountOut, message: "Output amount too small")

    fusdVault.deposit(from: <- token2Vault)
  }
}