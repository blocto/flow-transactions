import BloctoPass from 0x7deafdfc288e422d

transaction(amount: UFix64, index: Int) {
  // The private reference to user's BloctoPass
  let bloctoPassRef: &BloctoPass.NFT

  prepare(account: AuthAccount) {
    // Get a reference to the account's BloctoPass
    let bloctoPassCollectionRef = account.borrow<&BloctoPass.Collection>(from: /storage/bloctoPassCollection)
      ?? panic("Could not borrow reference to the owner's BloctoPass collection!")

    let ids = bloctoPassCollectionRef.getIDs()

    // Get a reference to the BloctoPass
    self.bloctoPassRef = bloctoPassCollectionRef.borrowBloctoPassPrivate(id: ids[index])
  }

  execute {
    self.bloctoPassRef.requestUnstaking(amount: amount)
  }
}