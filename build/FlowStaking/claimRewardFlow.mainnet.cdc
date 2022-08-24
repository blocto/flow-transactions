import LockedTokens from 0x8d0e87b65159ae63
import FlowToken from 0x1654653399040a61

transaction(amount: UFix64) {
  let nodeDelegatorProxy: LockedTokens.LockedNodeDelegatorProxy
  let holderRef: &LockedTokens.TokenHolder
  let vaultRef: &FlowToken.Vault

  prepare(acct: AuthAccount) {
    self.holderRef = acct.borrow<&LockedTokens.TokenHolder>(from: LockedTokens.TokenHolderStoragePath) 
      ?? panic("TokenHolder is not saved at specified path")
    
    self.nodeDelegatorProxy = self.holderRef.borrowDelegator()

    self.vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
      ?? panic("Could not borrow flow token vault ref")
  }

  execute {
    self.nodeDelegatorProxy.withdrawRewardedTokens(amount: amount)
    self.vaultRef.deposit(from: <-self.holderRef.withdraw(amount: amount))
  }
}