
import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0xFLOVATAR_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS


transaction(
    componentId: UInt64,
    price: UFix64) {

    let componentCollection: &FlovatarComponent.Collection
    let marketplace: &FlovatarMarketplace.SaleCollection

    prepare(account: AuthAccount) {

        let marketplaceCap = account.getCapability<&{FlovatarMarketplace.SalePublic}>(FlovatarMarketplace.CollectionPublicPath)
        // if sale collection is not created yet we make it.
        if !marketplaceCap.check() {
             let wallet =  account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
             let sale <- FlovatarMarketplace.createSaleCollection(ownerVault: wallet)

            // store an empty NFT Collection in account storage
            account.save<@FlovatarMarketplace.SaleCollection>(<- sale, to:FlovatarMarketplace.CollectionStoragePath)
            // publish a capability to the Collection in storage
            account.link<&{FlovatarMarketplace.SalePublic}>(FlovatarMarketplace.CollectionPublicPath, target: FlovatarMarketplace.CollectionStoragePath)
        }

        self.marketplace = account.borrow<&FlovatarMarketplace.SaleCollection>(from: FlovatarMarketplace.CollectionStoragePath)!
        self.componentCollection = account.borrow<&FlovatarComponent.Collection>(from: FlovatarComponent.CollectionStoragePath)!
    }

    execute {
        let component <- self.componentCollection.withdraw(withdrawID: componentId) as! @FlovatarComponent.NFT
        self.marketplace.listFlovatarComponentForSale(token: <- component, price: price)
    }
}
