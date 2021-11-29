import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x921ea449dffec68a
import NonFungibleToken from 0x1d7e57aa55817448
import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61


//this transaction buy a Flovatar Component from a direct sale listing from another user
transaction(saleAddress: Address, tokenId: UInt64, amount: UFix64) {

    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let collectionCap: Capability<&{FlovatarComponent.CollectionPublic}>
    // Vault that will hold the tokens that will be used
    // to buy the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(account: AuthAccount) {

        // get the references to the buyer's Vault and NFT Collection receiver
        var collectionCap = account.getCapability<&{FlovatarComponent.CollectionPublic}>(FlovatarComponent.CollectionPublicPath)

        // if collection is not created yet we make it.
        if !collectionCap.check() {
            // store an empty NFT Collection in account storage
            account.save<@NonFungibleToken.Collection>(<- FlovatarComponent.createEmptyCollection(), to: FlovatarComponent.CollectionStoragePath)
            // publish a capability to the Collection in storage
            account.link<&{FlovatarComponent.CollectionPublic}>(FlovatarComponent.CollectionPublicPath, target: FlovatarComponent.CollectionStoragePath)
        }



        self.collectionCap = collectionCap

        self.vaultCap = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ?? panic("Could not borrow owner's Vault reference")

        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(saleAddress)

        let marketplace = seller.getCapability(FlovatarMarketplace.CollectionPublicPath).borrow<&{FlovatarMarketplace.SalePublic}>()
                         ?? panic("Could not borrow seller's sale reference")

        marketplace.purchaseFlovatarComponent(tokenId: tokenId, recipientCap:self.collectionCap, buyTokens: <- self.temporaryVault)
    }

}