import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import FUSD from 0xe223d8a629e49c68
import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, Marketplace from 0x4d23ef75f1c37187
/*
    Transaction to purchase a pack by passing a secret signature
 */

transaction(saleAddress: Address, tokenId: UInt64, amount: UFix64, signature: String) {

    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let collectionCap: Capability<&{FlovatarPack.CollectionPublic}>
    // Vault that will hold the tokens that will be used
    // to buy the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(account: AuthAccount) {

        let flovatarPackCap = account.getCapability<&{FlovatarPack.CollectionPublic}>(FlovatarPack.CollectionPublicPath)
        if(!flovatarPackCap.check()) {
            let wallet =  account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)
            account.save<@FlovatarPack.Collection>(<- FlovatarPack.createEmptyCollection(ownerVault: wallet), to: FlovatarPack.CollectionStoragePath)
            account.link<&{FlovatarPack.CollectionPublic}>(FlovatarPack.CollectionPublicPath, target: FlovatarPack.CollectionStoragePath)
        }

        if(account.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil) {
          account.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
          account.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
          account.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }


        self.collectionCap = flovatarPackCap

        self.vaultCap = account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)

        let vaultRef = account.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow owner's Vault reference")

        // withdraw tokens from the buyer's Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(saleAddress)

        let packmarket = seller.getCapability(FlovatarPack.CollectionPublicPath).borrow<&{FlovatarPack.CollectionPublic}>()
                         ?? panic("Could not borrow seller's sale reference")

        packmarket.purchase(tokenId: tokenId, recipientCap: self.collectionCap, buyTokens: <- self.temporaryVault, signature: signature)
    }

}