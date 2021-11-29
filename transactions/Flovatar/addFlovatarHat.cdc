
import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0xFLOVATAR_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS

//this transaction will add a new Hat to an existing Flovatar
transaction(
    flovatarId: UInt64,
    hat: UInt64
    ) {

    let flovatarCollection: &Flovatar.Collection
    let flovatarComponentCollection: &FlovatarComponent.Collection

    let hatNFT: @FlovatarComponent.NFT

    prepare(account: AuthAccount) {
        self.flovatarCollection = account.borrow<&Flovatar.Collection>(from: Flovatar.CollectionStoragePath)!

        self.flovatarComponentCollection = account.borrow<&FlovatarComponent.Collection>(from: FlovatarComponent.CollectionStoragePath)!

        self.hatNFT <- self.flovatarComponentCollection.withdraw(withdrawID: hat) as! @FlovatarComponent.NFT
    }

    execute {

        let flovatar: &{Flovatar.Private} = self.flovatarCollection.borrowFlovatarPrivate(id: flovatarId)!

        let hat <-flovatar.setHat(component: <-self.hatNFT)
        if(hat != nil){
            self.flovatarComponentCollection.deposit(token: <-hat!)
        } else {
            destroy hat
        }
    }
}
