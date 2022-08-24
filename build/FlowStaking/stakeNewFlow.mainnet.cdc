import FungibleToken from 0xf233dcee88fe0abe
import LockedTokens from 0x8d0e87b65159ae63
import FlowToken from 0x1654653399040a61
import FlowStorageFees from 0xe467b9dd11fa00df

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