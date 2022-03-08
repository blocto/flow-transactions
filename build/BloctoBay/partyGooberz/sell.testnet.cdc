import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import NFTStorefront from 0x94b06cfca1d8a476
import Marketplace from 0xe1aa310cfe7750c4
import FlowToken from 0x7e60df042a9c0868
import GooberXContract from 0x0

transaction(saleItemID: UInt64, saleItemPrice: UFix64) {
    let tokenReceiver: Capability<&{FungibleToken.Receiver}>
    let nftProvider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let storefrontPublic: Capability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>

    prepare(signer: AuthAccount) {
        // Create Storefront if it doesn't exist
        if signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            let storefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront
            signer.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)
            signer.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath,
                target: NFTStorefront.StorefrontStoragePath)
        }

        // We need a provider capability, but one is not provided by default so we create one if needed.
        let nftCollectionProviderPrivatePath = /private/GooberXContractCollectionProviderForNFTStorefront
        if !signer.getCapability<&GooberXContract.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath)!.check() {
            signer.link<&GooberXContract.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath, target: GooberXContract.CollectionStoragePath)
        }

        self.tokenReceiver = signer.getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(self.tokenReceiver.borrow() != nil, message: "Missing or mis-typed FlowToken receiver")

        self.nftProvider = signer.getCapability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath)!
        assert(self.nftProvider.borrow() != nil, message: "Missing or mis-typed Collection provider")

        self.storefront = signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        self.storefrontPublic = signer.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        assert(self.storefrontPublic.borrow() != nil, message: "Could not borrow public storefront from address")
    }

    execute {
        // Remove old listing
        if let listingID = Marketplace.getListingID(nftType: Type<@GooberXContract.NFT>(), nftID: saleItemID) {
            let listingIDs = self.storefront.getListingIDs()
            if listingIDs.contains(listingID) {
                self.storefront.removeListing(listingResourceID: listingID)
            }
            Marketplace.removeListing(id: listingID)
        }

        // Create SaleCuts
        var saleCuts: [NFTStorefront.SaleCut] = []
        let requirements = Marketplace.getSaleCutRequirements(nftType: Type<@GooberXContract.NFT>())
        var remainingPrice = saleItemPrice
        for requirement in requirements {
            let price = saleItemPrice * requirement.ratio
            saleCuts.append(NFTStorefront.SaleCut(
                receiver: requirement.receiver,
                amount: price
            ))
            remainingPrice = remainingPrice - price
        }
        saleCuts.append(NFTStorefront.SaleCut(
            receiver: self.tokenReceiver,
            amount: remainingPrice
        ))

        // Add listing
        let id = self.storefront.createListing(
            nftProviderCapability: self.nftProvider,
            nftType: Type<@GooberXContract.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: saleCuts
        )
        Marketplace.addListing(id: id, storefrontPublicCapability: self.storefrontPublic)
    }
}