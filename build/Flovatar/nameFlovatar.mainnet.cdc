import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x921ea449dffec68a
import NonFungibleToken from 0x1d7e57aa55817448
import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61

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