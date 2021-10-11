import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import Art, Auction, Versus from 0xVERSUS_ADDRESS
/*
    Transaction to make a bid in a marketplace for the given dropId and auctionId
 */
transaction(marketplace: Address, dropId: UInt64, auctionId: UInt64, bidAmount: UFix64) {
    // reference to the buyer's NFT collection where they
    // will store the bought NFT
    let vaultCap: Capability<&{FungibleToken.Receiver}>
    let collectionCap: Capability<&{Art.CollectionPublic}>
    let versusCap: Capability<&{Versus.PublicDrop}>
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
        let seller = getAccount(marketplace)
        self.versusCap = seller.getCapability<&{Versus.PublicDrop}>(Versus.CollectionPublicPath)
        let currentBid=self.versusCap.borrow()!.currentBidForUser(dropId: dropId, auctionId: auctionId, address: account.address)
        //if your capability is the leader you only have to send in the difference
        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: bidAmount - currentBid)
    }
    execute {
        self.versusCap.borrow()!.placeBid(dropId: dropId, auctionId: auctionId, bidTokens: <- self.temporaryVault, vaultCap: self.vaultCap, collectionCap: self.collectionCap)
    }
}
