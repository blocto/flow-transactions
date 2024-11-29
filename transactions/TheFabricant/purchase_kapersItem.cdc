import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken
    import FlowToken from 0xFlowToken
    import TheFabricantKapers from 0xTheFabricantKapers
    import TheFabricantMarketplace from 0xTheFabricantMarketplace
    import MetadataViews from 0xMetadataViews

    transaction(
        sellerAddress: Address, 
        listingID: String, 
        amount: UFix64
        ) {
        // reference to the buyer's NFT collection where they
        // will store the bought NFT
        let itemNFTCollection: &TheFabricantKapers.Collection{NonFungibleToken.Receiver}
        // Vault that will hold the tokens that will be used to buy the NFT
        let temporaryVault: @FungibleToken.Vault
        prepare(acct: AuthAccount) {

            // initialize S2ItemNFT
            if !acct.getCapability<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantKapers.TheFabricantKapersCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath).check() {
                if acct.type(at: TheFabricantKapers.TheFabricantKapersCollectionStoragePath) == nil {
                    let collection <- TheFabricantKapers.createEmptyCollection() as! @TheFabricantKapers.Collection
                    acct.save(<-collection, to: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
                }
                acct.unlink(TheFabricantKapers.TheFabricantKapersCollectionPublicPath)
                acct.link<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantKapers.TheFabricantKapersCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath, target: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
            }

            self.itemNFTCollection = acct.borrow<&TheFabricantKapers.Collection{NonFungibleToken.Receiver}>(from: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
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