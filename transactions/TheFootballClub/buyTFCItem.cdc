import FUSD from 0xFUSD_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import TFCItems from 0xTFC_ITEMS_ADDRESS
import NFTStorefront from 0xNFT_STOREFRONT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS

/*
    This transaction is used to buy a TFCItem for FUSD
 */
transaction(storefrontAddress: Address, listingResourceID: UInt64, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let TFCItemsCollection: &TFCItems.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(acct: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let mainFlowVault = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        self.TFCItemsCollection = acct.borrow<&TFCItems.Collection{NonFungibleToken.Receiver}>(
            from: TFCItems.CollectionStoragePath
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.TFCItemsCollection.deposit(token: <-item)
        
        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}