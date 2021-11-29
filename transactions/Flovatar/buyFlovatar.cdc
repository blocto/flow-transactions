
import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0xFLOVATAR_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS

//this transaction buy a Flovatar from a direct sale listing from another user
transaction(saleAddress: Address, tokenId: UInt64, amount: UFix64) {

    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let collectionCap: Capability<&{Flovatar.CollectionPublic}>
    // Vault that will hold the tokens that will be used
    // to buy the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(account: AuthAccount) {

        // get the references to the buyer's Vault and NFT Collection receiver
        var collectionCap = account.getCapability<&{Flovatar.CollectionPublic}>(Flovatar.CollectionPublicPath)

        // if collection is not created yet we make it.
        if !collectionCap.check() {
            // store an empty NFT Collection in account storage
            account.save<@NonFungibleToken.Collection>(<- Flovatar.createEmptyCollection(), to: Flovatar.CollectionStoragePath)
            // publish a capability to the Collection in storage
            account.link<&{Flovatar.CollectionPublic}>(Flovatar.CollectionPublicPath, target: Flovatar.CollectionStoragePath)
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

        marketplace.purchaseFlovatar(tokenId: tokenId, recipientCap:self.collectionCap, buyTokens: <- self.temporaryVault)
    }

}
