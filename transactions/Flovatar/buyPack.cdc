
import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0xFLOVATAR_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS

//this transaction buy a Pack
transaction(saleAddress: Address, tokenId: UInt64, amount: UFix64, signature: String) {

    // reference to the buyer's NFT collection where they
    // will store the bought NFT

    let vaultCap: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let collectionCap: Capability<&{FlovatarPack.CollectionPublic}>
    // Vault that will hold the tokens that will be used
    // to buy the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(account: AuthAccount) {

        let flovatarPackCap = account.getCapability<&{FlovatarPack.CollectionPublic}>(FlovatarPack.CollectionPublicPath)
        if(!flovatarPackCap.check()) {
            let wallet =  account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            account.save<@FlovatarPack.Collection>(<- FlovatarPack.createEmptyCollection(ownerVault: wallet), to: FlovatarPack.CollectionStoragePath)
            account.link<&{FlovatarPack.CollectionPublic}>(FlovatarPack.CollectionPublicPath, target: FlovatarPack.CollectionStoragePath)
        }


        self.collectionCap = flovatarPackCap

        self.vaultCap = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ?? panic("Could not borrow owner's Vault reference")

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
