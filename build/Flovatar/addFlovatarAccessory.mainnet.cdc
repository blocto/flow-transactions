import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x921ea449dffec68a
import NonFungibleToken from 0x1d7e57aa55817448
import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61

//this transaction will add a new Accessory to an existing Flovatar
transaction(
    flovatarId: UInt64,
    accessory: UInt64
    ) {

    let flovatarCollection: &Flovatar.Collection
    let flovatarComponentCollection: &FlovatarComponent.Collection

    let accessoryNFT: @FlovatarComponent.NFT

    prepare(account: AuthAccount) {
        self.flovatarCollection = account.borrow<&Flovatar.Collection>(from: Flovatar.CollectionStoragePath)!

        self.flovatarComponentCollection = account.borrow<&FlovatarComponent.Collection>(from: FlovatarComponent.CollectionStoragePath)!

        self.accessoryNFT <- self.flovatarComponentCollection.withdraw(withdrawID: accessory) as! @FlovatarComponent.NFT
    }

    execute {

        let flovatar: &{Flovatar.Private} = self.flovatarCollection.borrowFlovatarPrivate(id: flovatarId)!

        let accessory <-flovatar.setAccessory(component: <-self.accessoryNFT)
        if(accessory != nil){
            self.flovatarComponentCollection.deposit(token: <-accessory!)
        } else {
            destroy accessory
        }
    }
}