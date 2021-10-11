import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import Content, Art, Auction, Versus, Marketplace from 0xd796ff17107bbff6

transaction(marketplace: Address, tokenId: UInt64, amount: UFix64) {
  // reference to the buyer's NFT collection where they
  // will store the bought NFT

  let vaultCap: Capability<&{FungibleToken.Receiver}>
    let collectionCap: Capability<&{Art.CollectionPublic}>
    // Vault that will hold the tokens that will be used
    // to buy the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(account: AuthAccount) {

      // get the references to the buyer's Vault and NFT Collection receiver
      var collectionCap = account.getCapability<&{Art.CollectionPublic}>(Art.CollectionPublicPath)

        // if collection is not created yet we make it.
        if !collectionCap.check() {
          // store an empty NFT Collection in account storage
          account.save<@NonFungibleToken.Collection>(<- Art.createEmptyCollection(), to: Art.CollectionStoragePath)

            // publish a capability to the Collection in storage
            account.link<&{Art.CollectionPublic}>(Art.CollectionPublicPath, target: Art.CollectionStoragePath)
        }

      self.collectionCap=collectionCap

        self.vaultCap = account.getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
        ?? panic("Could not borrow owner's Vault reference")

        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount)
    }

  execute {
    // get the read-only account storage of the seller
    let seller = getAccount(marketplace)

      let marketplace= seller.getCapability(Marketplace.CollectionPublicPath).borrow<&{Marketplace.SalePublic}>()
      ?? panic("Could not borrow seller's sale reference")

      marketplace.purchase(tokenID: tokenId, recipientCap:self.collectionCap, buyTokens: <- self.temporaryVault)
  }
}
