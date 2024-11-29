import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken
    import FlowToken from 0xFlowToken
    import TheFabricantMarketplace from 0xTheFabricantMarketplace
    import TheFabricantMarketplaceHelper from 0xTheFabricantMarketplaceHelper
    import TheFabricantS2ItemNFT from 0xTheFabricantS2ItemNFT

    transaction(itemID: UInt64, price: UFix64) {
        let itemCollectionRef: &TheFabricantS2ItemNFT.Collection
        let listingRef: &TheFabricantMarketplace.Listings
        let flowReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
        let itemNFTProvider: Capability<&TheFabricantS2ItemNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>

        prepare(acct: AuthAccount) {

            // borrow a reference to self's item collection
            self.itemCollectionRef = acct.borrow<&TheFabricantS2ItemNFT.Collection>(from: TheFabricantS2ItemNFT.${collectionStoragePathPrefix}CollectionStoragePath)
                ?? panic("Could not borrow item in storage")

            // get listings Capability
            let listingCap = acct.getCapability<&{TheFabricantMarketplace.ListingsPublic}>(TheFabricantMarketplace.ListingsPublicPath)

            // get flow token Capability
            self.flowReceiver = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            assert(self.flowReceiver.check(), message: "Missing or mis-typed FlowToken receiver")

            // initialize private path to withdraw your nft once it is purchased
            let NFTCollectionProviderPrivatePath = ${providerPrivatePath}
            if !acct.getCapability<&TheFabricantS2ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Provider}>(NFTCollectionProviderPrivatePath).check() {
                acct.unlink(NFTCollectionProviderPrivatePath)
                acct.link<&TheFabricantS2ItemNFT.Collection{TheFabricantS2ItemNFT.${publicCollPrefix}CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Provider}>(NFTCollectionProviderPrivatePath, target: TheFabricantS2ItemNFT.${collectionStoragePathPrefix}CollectionStoragePath)
            }

            // get nft provider capability
            self.itemNFTProvider = acct.getCapability<&TheFabricantS2ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Provider}>(NFTCollectionProviderPrivatePath)
            assert(self.itemNFTProvider.check(), message: "Missing or mis-typed TheFabricantS2ItemNFT.Collection provider")

            if !listingCap.check() {

                // get own flow token capability
                let wallet = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

                // create listings
                let listings <- TheFabricantMarketplace.createListings()

                // store an empty listings
                acct.save<@TheFabricantMarketplace.Listings>(<- listings, to: TheFabricantMarketplace.ListingsStoragePath)

                // publish a public capability to the Listings in storage
                acct.link<&{TheFabricantMarketplace.ListingsPublic}>(TheFabricantMarketplace.ListingsPublicPath, target: TheFabricantMarketplace.ListingsStoragePath)
            }

            self.listingRef=acct.borrow<&TheFabricantMarketplace.Listings>(from: TheFabricantMarketplace.ListingsStoragePath)!
        }

        execute {

            let itemRef = self.itemCollectionRef.borrow${borrowName}(id: itemID)! as &TheFabricantS2ItemNFT.NFT
                
            //list the item
            TheFabricantMarketplaceHelper.${mpHelper}(
                itemRef: itemRef,
                ${listingsRefKey}: self.listingRef,
                nftProviderCapability: self.itemNFTProvider,
                nftType: Type<@TheFabricantS2ItemNFT.NFT>(),
                nftID: itemID,
                paymentCapability: self.flowReceiver,
                salePaymentVaultType: Type<@FlowToken.Vault>(),
                price: price
            )
        }
    }