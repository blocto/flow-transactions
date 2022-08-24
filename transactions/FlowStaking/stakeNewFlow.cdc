import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import LockedTokens from 0xLOCKED_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import FlowStorageFees from 0xFLOW_STORAGE_FEES_ADDRESS

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