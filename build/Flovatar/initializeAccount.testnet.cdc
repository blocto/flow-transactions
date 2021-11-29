import Flovatar, FlovatarComponent, FlovatarComponentTemplate, FlovatarPack, FlovatarMarketplace from 0x0cf264811b95d465
import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868


transaction {
  // We want the account's address for later so we can verify if the account was initialized properly
  let address: Address

  prepare(account: AuthAccount) {
    // save the address for the post check
    self.address = account.address


    let flovatarCap = account.getCapability<&{Flovatar.CollectionPublic}>(Flovatar.CollectionPublicPath)
    if(!flovatarCap.check()) {
        // store an empty NFT Collection in account storage
        account.save<@NonFungibleToken.Collection>(<- Flovatar.createEmptyCollection(), to: Flovatar.CollectionStoragePath)

        // publish a capability to the Collection in storage
        account.link<&{Flovatar.CollectionPublic}>(Flovatar.CollectionPublicPath, target: Flovatar.CollectionStoragePath)
    }

    let flovatarComponentCap = account.getCapability<&{FlovatarComponent.CollectionPublic}>(FlovatarComponent.CollectionPublicPath)
    if(!flovatarComponentCap.check()) {
        account.save<@NonFungibleToken.Collection>(<- FlovatarComponent.createEmptyCollection(), to: FlovatarComponent.CollectionStoragePath)
        account.link<&{FlovatarComponent.CollectionPublic}>(FlovatarComponent.CollectionPublicPath, target: FlovatarComponent.CollectionStoragePath)
    }

    let flovatarPackCap = account.getCapability<&{FlovatarPack.CollectionPublic}>(FlovatarPack.CollectionPublicPath)
    if(!flovatarPackCap.check()) {
        let wallet =  account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        account.save<@FlovatarPack.Collection>(<- FlovatarPack.createEmptyCollection(ownerVault: wallet), to: FlovatarPack.CollectionStoragePath)
        account.link<&{FlovatarPack.CollectionPublic}>(FlovatarPack.CollectionPublicPath, target: FlovatarPack.CollectionStoragePath)
    }

    let marketplaceCap = account.getCapability<&{FlovatarMarketplace.SalePublic}>(FlovatarMarketplace.CollectionPublicPath)
    if(!marketplaceCap.check()) {
        let wallet =  account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        // store an empty Sale Collection in account storage
        account.save<@FlovatarMarketplace.SaleCollection>(<- FlovatarMarketplace.createSaleCollection(ownerVault: wallet), to:FlovatarMarketplace.CollectionStoragePath)

        // publish a capability to the Collection in storage
        account.link<&{FlovatarMarketplace.SalePublic}>(FlovatarMarketplace.CollectionPublicPath, target: FlovatarMarketplace.CollectionStoragePath)
    }

  }

}