import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x0cf264811b95d465
import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

transaction(packId: UInt64) {

    let flovatarPackCollection: &FlovatarPack.Collection

    prepare(account: AuthAccount) {
        self.flovatarPackCollection = account.borrow<&FlovatarPack.Collection>(from: FlovatarPack.CollectionStoragePath)!
    }

    execute {
        self.flovatarPackCollection.openPack(id: packId)
    }

}