import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTStorefront from 0x4eb8a10cb9f87357
import FlowToken from 0x1654653399040a61
import TheFabricantMysteryBox_FF1 from 0xa0cbe021821c0965

transaction(saleItemID: UInt64, saleItemPrice: UFix64, saleCutPercents: {Address: UFix64}) {
    let flowTokenReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let nftProvider: Capability<&TheFabricantMysteryBox_FF1.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let storefrontPublic: Capability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>
    let saleCuts: [NFTStorefront.SaleCut]

    prepare(signer: AuthAccount) {
        if signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            signer.save(<-NFTStorefront.createStorefront(), to: NFTStorefront.StorefrontStoragePath)
            signer.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath, target: NFTStorefront.StorefrontStoragePath)
        }

        let nftCollectionProviderPrivatePath = /private/fabricantMysteryBoxCollectionProviderForNFTStorefront
        if !signer.getCapability<&TheFabricantMysteryBox_FF1.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath)!.check() {
            signer.link<&TheFabricantMysteryBox_FF1.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath, target: TheFabricantMysteryBox_FF1.CollectionStoragePath)
        }

        self.flowTokenReceiver = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(self.flowTokenReceiver.borrow() != nil, message: "Missing or mis-typed FlowToken receiver")

        self.nftProvider = signer.getCapability<&TheFabricantMysteryBox_FF1.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath)!
        assert(self.nftProvider.borrow() != nil, message: "Missing or mis-typed TheFabricantMysteryBox_FF1.Collection provider")

        self.storefront = signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        self.storefrontPublic = signer.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        assert(self.storefrontPublic.borrow() != nil, message: "Could not borrow public storefront from address")

        self.saleCuts = [];
        var remainingPrice = saleItemPrice
        for address in saleCutPercents.keys {
            let account = getAccount(address);
            let saleCutFlowTokenReceiver = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
            assert(saleCutFlowTokenReceiver.borrow() != nil, message: "Missing or mis-typed FlowToken receiver")
            let amount = saleItemPrice * saleCutPercents[address]!
            self.saleCuts.append(NFTStorefront.SaleCut(
                receiver: saleCutFlowTokenReceiver,
                amount: amount
            ))
            remainingPrice = remainingPrice - amount
        }
        self.saleCuts.append(NFTStorefront.SaleCut(
            receiver: self.flowTokenReceiver,
            amount: remainingPrice
        ))
    }

    execute {
        self.storefront.createListing(
            nftProviderCapability: self.nftProvider,
            nftType: Type<@TheFabricantMysteryBox_FF1.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: self.saleCuts
        )
    }
}