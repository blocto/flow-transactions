import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import BloctoToken from 0x6e0797ac987005f5
import BloctoPass from 0x7deafdfc288e422d

transaction(amount: UFix64, index: Int) {

  // The Vault resource that holds the tokens that are being transferred
  let vaultRef: &BloctoToken.Vault

  // The private reference to user's BloctoPass
  let bloctoPassRef: &BloctoPass.NFT

  prepare(signer: AuthAccount) {

    // BloctoToken Vault
    if signer.borrow<&BloctoToken.Vault>(from: BloctoToken.TokenStoragePath) == nil {
      // Create a new Blocto Token Vault and put it in storage
      signer.save(<-BloctoToken.createEmptyVault(), to: BloctoToken.TokenStoragePath)

      // Create a public capability to the Vault that only exposes
      // the deposit function through the Receiver interface
      signer.link<&BloctoToken.Vault{FungibleToken.Receiver}>(
        BloctoToken.TokenPublicReceiverPath,
        target: BloctoToken.TokenStoragePath
      )

      // Create a public capability to the Vault that only exposes
      // the balance field through the Balance interface
      signer.link<&BloctoToken.Vault{FungibleToken.Balance}>(
        BloctoToken.TokenPublicBalancePath,
        target: BloctoToken.TokenStoragePath
      )
    }

    // BloctoPass Collection
    if signer.borrow<&BloctoPass.Collection>(from: /storage/bloctoPassCollection) == nil {
      signer.save(<-BloctoPass.createEmptyCollection(), to: /storage/bloctoPassCollection)

      signer.link<&{NonFungibleToken.CollectionPublic, BloctoPass.CollectionPublic}>(
        /public/bloctoPassCollection,
        target: /storage/bloctoPassCollection
      )
    }

    let collectionRef = signer.getCapability(/public/bloctoPassCollection)!
      .borrow<&{NonFungibleToken.CollectionPublic, BloctoPass.CollectionPublic}>()
      ?? panic("Could not borrow collection public reference")

    if collectionRef.getIDs().length == 0 {
      let minterRef = getAccount(0x7deafdfc288e422d).getCapability(/public/bloctoPassMinter)
        .borrow<&{BloctoPass.MinterPublic}>()
        ?? panic("Could not borrow minter public reference")

      minterRef.mintBasicNFT(recipient: collectionRef) 
    }

    // Get a reference to the account's stored vault
    self.vaultRef = signer.borrow<&BloctoToken.Vault>(from: BloctoToken.TokenStoragePath)
      ?? panic("Could not borrow reference to the owner's Vault!")

    // Get a reference to the account's BloctoPass
    let bloctoPassCollectionRef = signer.borrow<&BloctoPass.Collection>(from: /storage/bloctoPassCollection)
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