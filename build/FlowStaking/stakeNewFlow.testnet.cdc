import FungibleToken from 0x9a0766d93b6608b7
import LockedTokens from 0x95e019a17d0e23d7
import FlowToken from 0x7e60df042a9c0868
import FlowStorageFees from 0x8c5303eaa26202d6

transaction(amount: UFix64) {

  let holderRef: &LockedTokens.TokenHolder

  let vaultRef: &FlowToken.Vault

  prepare(account: AuthAccount) {
    self.holderRef = account.borrow<&LockedTokens.TokenHolder>(from: LockedTokens.TokenHolderStoragePath)
      ?? panic("Could not borrow reference to TokenHolder")

    self.vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
      ?? panic("Could not borrow flow token vault reference")
  }

  execute {
    let delegatorProxy = self.holderRef.borrowDelegator()
    let lockedBalance = self.holderRef.getLockedAccountBalance()

    if amount <= lockedBalance {
      delegatorProxy.delegateNewTokens(amount: amount)
    } else if ((amount - lockedBalance) <= self.vaultRef.balance - FlowStorageFees.minimumStorageReservation) {
      self.holderRef.deposit(from: <-self.vaultRef.withdraw(amount: amount - lockedBalance))
      delegatorProxy.delegateNewTokens(amount: amount)
    } else {
      panic("Not enough tokens to stake!")
    }
  }
}