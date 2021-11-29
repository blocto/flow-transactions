import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x921ea449dffec68a
import NonFungibleToken from 0x1d7e57aa55817448
import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61

transaction(
    componentId: UInt64
    ) {

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
        let component <- self.marketplace.withdrawFlovatarComponent(tokenId: componentId)
        self.componentCollection.deposit(token: <- component);
    }
}