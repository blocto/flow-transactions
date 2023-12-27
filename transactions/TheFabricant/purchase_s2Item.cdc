import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken
    import FlowToken from 0xFlowToken
    import TheFabricantS2ItemNFT from 0xTheFabricantS2ItemNFT
    import TheFabricantMarketplace from 0xTheFabricantMarketplace

    transaction(sellerAddress: Address, listingID: String, amount: UFix64) {
    // reference to the buyer's NFT collection where they
    // will store the bought NFT
    let itemNFTCollection: &TheFabricantS2ItemNFT.Collection{NonFungibleToken.Receiver}
    // Vault that will hold the tokens that will be used to buy the NFT
    let temporaryVault: @FungibleToken.Vault
    prepare(acct: AuthAccount) {
        if !acct.getCapability<&{TheFabricantS2ItemNFT.ItemCollectionPublic}>(TheFabricantS2ItemNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS2ItemNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS2ItemNFT.createEmptyCollection() as! @TheFabricantS2ItemNFT.Collection
                acct.save(<-collection, to: TheFabricantS2ItemNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS2ItemNFT.CollectionPublicPath)
            acct.link<&{TheFabricantS2ItemNFT.ItemCollectionPublic}>(TheFabricantS2ItemNFT.CollectionPublicPath, target: TheFabricantS2ItemNFT.CollectionStoragePath)
        }
        self.itemNFTCollection = acct.borrow<&TheFabricantS2ItemNFT.Collection{NonFungibleToken.Receiver}>(from: TheFabricantS2ItemNFT.CollectionStoragePath)
            ?? panic("could not borrow owner's nft collection reference")
        
        let vaultRef = acct.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow owner's Vault reference")

        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // get the read-only acct storage of the seller
        let seller = getAccount(sellerAddress)

        let listingRef= seller.getCapability(TheFabricantMarketplace.ListingsPublicPath).borrow<&{TheFabricantMarketplace.ListingsPublic}>()
                        ?? panic("Could not borrow seller's listings reference")

        listingRef.purchaseListing(listingID: listingID, recipientCap: self.itemNFTCollection, payment: <- self.temporaryVault)
    }
    }