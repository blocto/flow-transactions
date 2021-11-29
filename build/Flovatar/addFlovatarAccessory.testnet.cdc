import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x0cf264811b95d465
import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

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