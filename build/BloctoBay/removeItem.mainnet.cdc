import NFTStorefront from 0x4eb8a10cb9f87357
import Marketplace from 0xdc5127882cacf8d9

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