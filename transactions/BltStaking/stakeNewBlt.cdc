import BloctoToken from 0xBLOCTO_TOKEN_ADDRESS
import BloctoPass from 0xBLOCTO_PASS_ADDRESS

transaction(amount: UFix64, index: Int) {

  // The Vault resource that holds the tokens that are being transferred
  let vaultRef: &BloctoToken.Vault

  // The private reference to user's BloctoPass
  let bloctoPassRef: &BloctoPass.NFT

  prepare(account: AuthAccount) {
    // Get a reference to the account's stored vault
    self.vaultRef = account.borrow<&BloctoToken.Vault>(from: BloctoToken.TokenStoragePath)
      ?? panic("Could not borrow reference to the owner's Vault!")

    // Get a reference to the account's BloctoPass
    let bloctoPassCollectionRef = account.borrow<&BloctoPass.Collection>(from: /storage/bloctoPassCollection)
      ?? panic("Could not borrow reference to the owner's BloctoPass collection!")

    let ids = bloctoPassCollectionRef.getIDs()

    // Get a reference to the BloctoPass
    self.bloctoPassRef = bloctoPassCollectionRef.borrowBloctoPassPrivate(id: ids[index])
  }

  execute {
    let lockedBalance = self.bloctoPassRef.getIdleBalance()

    if amount <= lockedBalance {
      self.bloctoPassRef.stakeNewTokens(amount: amount)
    } else if ((amount - lockedBalance) <= self.vaultRef.balance) {
      self.bloctoPassRef.deposit(from: <-self.vaultRef.withdraw(amount: amount - lockedBalance))
      self.bloctoPassRef.stakeNewTokens(amount: amount)
    } else {
      panic("Not enough tokens to stake!")
    }
  }
}