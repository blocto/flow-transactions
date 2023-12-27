import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken
    import FlowToken from 0xFlowToken
    import TheFabricantXXories from 0xTheFabricantXXories
    import TheFabricantMarketplace from 0xTheFabricantMarketplace
    import MetadataViews from 0xMetadataViews



    transaction(
        sellerAddress: Address, 
        listingID: String, 
        amount: UFix64
        ) {
        // reference to the buyer's NFT collection where they
        // will store the bought NFT
        let itemNFTCollection: &TheFabricantXXories.Collection{NonFungibleToken.Receiver}
        // Vault that will hold the tokens that will be used to buy the NFT
        let temporaryVault: @FungibleToken.Vault
        prepare(acct: AuthAccount) {

            // initialize S2ItemNFT
            if !acct.getCapability<&TheFabricantXXories.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantXXories.TheFabricantXXoriesCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantXXories.TheFabricantXXoriesCollectionPublicPath).check() {
                if acct.type(at: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath) == nil {
                    let collection <- TheFabricantXXories.createEmptyCollection() as! @TheFabricantXXories.Collection
                    acct.save(<-collection, to: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath)
                }
                acct.unlink(TheFabricantXXories.TheFabricantXXoriesCollectionPublicPath)
                acct.link<&TheFabricantXXories.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantXXories.TheFabricantXXoriesCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantXXories.TheFabricantXXoriesCollectionPublicPath, target: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath)
            }

            self.itemNFTCollection = acct.borrow<&TheFabricantXXories.Collection{NonFungibleToken.Receiver}>(from: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath)
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