import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import StarlyCard from 0x5b82f21c0edf76e3
import StarlyCardMarket from 0x5b82f21c0edf76e3

transaction(
    itemID: UInt64,
    price: UFix64,
    beneficiaryAddress: Address,
    beneficiaryCutPercent: UFix64,
    creatorAddress: Address,
    creatorCutPercent: UFix64) {

    let starlyCardCollection: Capability<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>
    let marketCollection: &StarlyCardMarket.Collection
    let sellerFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let beneficiaryFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let creatorFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>

    prepare(signer: AuthAccount) {
        // we need a provider capability, but one is not provided by default so we create one.
        let StarlyCardCollectionProviderPrivatePath = /private/starlyCardCollectionProvider
        if !signer.getCapability<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>(StarlyCardCollectionProviderPrivatePath)!.check() {
            signer.link<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>(StarlyCardCollectionProviderPrivatePath, target: StarlyCard.CollectionStoragePath)
        }

        self.starlyCardCollection = signer.getCapability<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>(StarlyCardCollectionProviderPrivatePath)!
        assert(self.starlyCardCollection.borrow() != nil, message: "Missing or mis-typed StarlyCardCollection provider")

        self.marketCollection = signer.borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath)
            ?? panic("Missing or mis-typed StarlyCardMarket Collection")

        self.sellerFUSDVault = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.sellerFUSDVault.borrow() != nil, message: "Missing or mis-typed seller FUSD receiver")

        let beneficiary = getAccount(beneficiaryAddress);
        self.beneficiaryFUSDVault = beneficiary.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.beneficiaryFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (beneficiary)")

        let creator = getAccount(creatorAddress)
        self.creatorFUSDVault = creator.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.creatorFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (creator)")

        assert(beneficiaryCutPercent + creatorCutPercent < 1.0, message: "Sum of beneficiaryCutPercent and creatorCutPercent should be below 1.0")
    }

    execute {
        let sellerCutPercent = 1.0 - beneficiaryCutPercent - creatorCutPercent;
        let offer <- StarlyCardMarket.createSaleOffer (
            itemID: itemID,
            starlyID: self.starlyCardCollection.borrow()!.borrowStarlyCard(id: itemID)!.starlyID,
            price: price,
            sellerItemProvider: self.starlyCardCollection,
            sellerSaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: self.sellerFUSDVault,
                percent: sellerCutPercent),
            beneficiarySaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: self.beneficiaryFUSDVault,
                percent: beneficiaryCutPercent),
            creatorSaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: self.creatorFUSDVault,
                percent: creatorCutPercent),
            additionalSaleCutReceivers: [])
        self.marketCollection.insert(offer: <-offer)
    }
}