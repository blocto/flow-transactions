import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTStorefront from 0x5b82f21c0edf76e3
import Marketplace from 0xdc5127882cacf8d9
import FlowToken from 0x1654653399040a61
import MotoGPCard from 0xa49cc0ee46c54bfb

prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&MotoGPCard.Collection>(from: /storage/motogpCardCollection) == nil {
            signer.save(<- MotoGPCard.createEmptyCollection(), to: /storage/motogpCardCollection)
            signer.link<&MotoGPCard.Collection{MotoGPCard.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/motogpCardCollection, target: /storage/motogpCardCollection)
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from signer storage")
        self.paymentVault <- flowTokenVault.withdraw(amount: price)

        self.MotoGPCardCollection = signer.borrow<&MotoGPCard.Collection{NonFungibleToken.Receiver}>(from: /storage/motogpCardCollection)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)

        self.MotoGPCardCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}