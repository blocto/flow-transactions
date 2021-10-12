import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, Marketplace from 0x0
/*
    Transaction to purchase a Flovatar Component from the Marketplace
 */
transaction(saleAddress: Address, tokenId: UInt64, amount: UFix64) {

    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: Capability<&FUSD.Vault{FungibleToken.Receiver}>
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


        if(account.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil) {
          account.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
          account.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
          account.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }


        self.collectionCap = collectionCap

        self.vaultCap = account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)

        let vaultRef = account.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow owner's Vault reference")

        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(saleAddress)

        let marketplace = seller.getCapability(Marketplace.CollectionPublicPath).borrow<&{Marketplace.SalePublic}>()
                         ?? panic("Could not borrow seller's sale reference")

        marketplace.purchaseFlovatarComponent(tokenId: tokenId, recipientCap:self.collectionCap, buyTokens: <- self.temporaryVault)
    }

}