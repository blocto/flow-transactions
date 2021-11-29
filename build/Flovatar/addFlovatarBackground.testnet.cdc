import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x0cf264811b95d465
import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

//this transaction will add a new Background to an existing Flovatar
transaction(
    flovatarId: UInt64,
    background: UInt64
    ) {

    let flovatarCollection: &Flovatar.Collection
    let flovatarComponentCollection: &FlovatarComponent.Collection

    let backgroundNFT: @FlovatarComponent.NFT

    prepare(account: AuthAccount) {
        self.flovatarCollection = account.borrow<&Flovatar.Collection>(from: Flovatar.CollectionStoragePath)!

        self.flovatarComponentCollection = account.borrow<&FlovatarComponent.Collection>(from: FlovatarComponent.CollectionStoragePath)!

        self.backgroundNFT <- self.flovatarComponentCollection.withdraw(withdrawID: background) as! @FlovatarComponent.NFT
    }

    execute {

        let flovatar: &{Flovatar.Private} = self.flovatarCollection.borrowFlovatarPrivate(id: flovatarId)!

        let background <-flovatar.setBackground(component: <-self.backgroundNFT)
        if(background != nil){
            self.flovatarComponentCollection.deposit(token: <-background!)
        } else {
            destroy background
        }
    }
}