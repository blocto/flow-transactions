import NFTStorefront from 0xNFTStorefront_ADDRESS
import Marketplace from 0xBLOCTO_BAY_MARKETPLACE_ADDRESS

transaction(listingResourceID: UInt64) {
    let storefrontManager: &NFTStorefront.Storefront{NFTStorefront.StorefrontManager}

    prepare(signer: AuthAccount) {
        self.storefrontManager = signer.borrow<&NFTStorefront.Storefront{NFTStorefront.StorefrontManager}>(
            from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront.Storefront")
    }

    execute {
        self.storefrontManager.removeListing(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }
}