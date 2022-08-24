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
    self.bloctoPassRef.withdrawRewardedTokens(amount: amount)

    // Unlock as much as possible
    let limit = self.bloctoPassRef.getTotalBalance() - self.bloctoPassRef.getLockupAmount()
    let max = limit > amount ? amount : limit

    self.vaultRef.deposit(from: <-self.bloctoPassRef.withdraw(amount: max))
  }
}