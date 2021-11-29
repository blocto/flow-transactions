import FUSD from 0xe223d8a629e49c68
import NonFungibleToken from 0x631e88ae7f1d7c20
import TFCItems from 0x91a6217c3b70cae8
import NFTStorefront from 0x94b06cfca1d8a476
import FungibleToken from 0x9a0766d93b6608b7

/*
    This transaction is used to sell a TFCItem for FUSD
 */
transaction(saleItemID: UInt64, saleItemPrice: UFix64) {
    let fusdReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let TFCItemsProvider: Capability<&TFCItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(acct: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let TFCItemsCollectionProviderPrivatePath = /private/TFCItemsCollectionProviderForNFTStorefront

        self.fusdReceiver = acct.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.fusdReceiver.borrow() != nil, message: "Missing or mis-typed FUSD receiver")

        if !acct.getCapability<&TFCItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(TFCItemsCollectionProviderPrivatePath)!.check() {
            acct.link<&TFCItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(TFCItemsCollectionProviderPrivatePath, target: TFCItems.CollectionStoragePath)
        }
        
        self.TFCItemsProvider = acct.getCapability<&TFCItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(TFCItemsCollectionProviderPrivatePath)!
        assert(self.TFCItemsProvider.borrow() != nil, message: "Missing or mis-typed TFCItems.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.fusdReceiver,
            amount: saleItemPrice
        )
        self.storefront.createListing(
            nftProviderCapability: self.TFCItemsProvider,
            nftType: Type<@TFCItems.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FUSD.Vault>(),
            saleCuts: [saleCut]
        )
    }
}