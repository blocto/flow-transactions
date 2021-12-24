import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import TFCItems from 0xTFC_ITEMS_ADDRESS
import NFTStorefront from 0xNFT_STOREFRONT_ADDRESS

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
