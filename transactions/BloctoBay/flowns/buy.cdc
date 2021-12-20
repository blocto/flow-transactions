import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import NFTStorefront from 0xNFT_STOREFRONT_ADDRESS
import Marketplace from 0xBLOCTO_BAY_MARKETPLACE_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import Domains from 0xFLOWNS_ADDRESS

transaction(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let nftCollection: &{NonFungibleToken.Receiver}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath) == nil {
            signer.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
            signer.link<&{NonFungibleToken.CollectionPublic, Domains.CollectionPublic}>(
			    Domains.CollectionPublicPath,
			    target: Domains.CollectionStoragePath
		    )
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let targetTokenVault = signer.borrow<&{FungibleToken.Provider}>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow target token vault from signer storage")
        self.paymentVault <- targetTokenVault.withdraw(amount: price)

        self.nftCollection = signer.borrow<&{NonFungibleToken.Receiver}>(from: Domains.CollectionStoragePath)
                    ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)
        self.nftCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}