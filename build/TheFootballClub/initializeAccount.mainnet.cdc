import NonFungibleToken from 0x1d7e57aa55817448
import TFCItems from 0x81e95660ab5308e1
import NFTStorefront from 0x4eb8a10cb9f87357

/*
    Check if an account has a TFCItems Collection capability
 */
pub fun hasItems(_ address: Address): Bool {
    return getAccount(address)
    .getCapability<&TFCItems.Collection{NonFungibleToken.CollectionPublic, TFCItems.TFCItemsCollectionPublic}>(TFCItems.CollectionPublicPath)
    .check()
}
/*
    Check if an account has a storefront capability
 */
pub fun hasStorefont(_ address: Address): Bool {
    return getAccount(address)
    .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
    .check()
}

/*
    This transaction configures an account to hold TFC Items & an NFTStorefont
 */
transaction {
    prepare(signer: AuthAccount) {
    

    // if a TFCItems collection is not created yet we make it.
    if !hasItems(signer.address) {
        if signer.borrow<&TFCItems.Collection>(from: TFCItems.CollectionStoragePath) == nil {
            signer.save(<-TFCItems.createEmptyCollection(), to: TFCItems.CollectionStoragePath)
            signer.unlink(TFCItems.CollectionPublicPath)
            signer.link<&TFCItems.Collection{NonFungibleToken.CollectionPublic, TFCItems.TFCItemsCollectionPublic}>(TFCItems.CollectionPublicPath, target: TFCItems.CollectionStoragePath)
        }
    }

    // if a NFTStorefront is not created yet we make it.
    if !hasStorefont(signer.address) {
        if signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            let storefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront        
            signer.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)
            signer.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath, target: NFTStorefront.StorefrontStoragePath)
        }
    }

    }
}