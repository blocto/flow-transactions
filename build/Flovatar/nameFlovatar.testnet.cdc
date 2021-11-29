import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x0cf264811b95d465
import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

//this transaction will set the name to an existing Flovatar
transaction(
    flovatarId: UInt64,
    name: String
    ) {

    let flovatarCollection: &Flovatar.Collection

    prepare(account: AuthAccount) {
        self.flovatarCollection = account.borrow<&Flovatar.Collection>(from: Flovatar.CollectionStoragePath)!
    }

    execute {

        let flovatar: &{Flovatar.Private} = self.flovatarCollection.borrowFlovatarPrivate(id: flovatarId)!

        flovatar.setName(name: name)
    }
}