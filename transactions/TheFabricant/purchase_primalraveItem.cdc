import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken
    import FlowToken from 0xFlowToken
    import TheFabricantMarketplace from 0xTheFabricantMarketplace
    import MetadataViews from 0xMetadataViews
    import TheFabricantPrimalRave from 0xTheFabricantPrimalRave



    transaction(
        sellerAddress: Address, 
        listingID: String, 
        amount: UFix64
        ) {
        // reference to the buyer's NFT collection where they
        // will store the bought NFT
        let itemNFTCollection: &TheFabricantPrimalRave.Collection{NonFungibleToken.Receiver}
        // Vault that will hold the tokens that will be used to buy the NFT
        let temporaryVault: @FungibleToken.Vault
        prepare(acct: AuthAccount) {

            // initialize S2ItemNFT
            if !acct.getCapability<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath).check() {
                if acct.type(at: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath) == nil {
                    let collection <- TheFabricantPrimalRave.createEmptyCollection() as! @TheFabricantPrimalRave.Collection
                    acct.save(<-collection, to: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
                }
                acct.unlink(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath)
                acct.link<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath, target: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
            }

            self.itemNFTCollection = acct.borrow<&TheFabricantPrimalRave.Collection{NonFungibleToken.Receiver}>(from: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
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