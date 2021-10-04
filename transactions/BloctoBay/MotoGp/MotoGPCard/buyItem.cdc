import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import NFTStorefront from 0xNFTStorefront_ADDRESS
import Marketplace from 0xBLOCTO_BAY_MARKETPLACE_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import MotoGPCard from 0xMOTO_GP_CARD_ADDRESS

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