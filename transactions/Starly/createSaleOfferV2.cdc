import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FlowStorageFees from 0xFLOW_STORAGE_FEES_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import StarlyCard from 0xSTARLY_CARD_ADDRESS
import StarlyCardMarket from 0xSTARLY_CARD_MARKET_ADDRESS

transaction(
    itemID: UInt64,
    price: UFix64,
    beneficiaryAddress: Address,
    beneficiaryCutPercent: UFix64,
    creatorAddress: Address,
    creatorCutPercent: UFix64) {

    prepare(signer: AuthAccount, admin: AuthAccount) {
        // we need a provider capability, but one is not provided by default so we create one.
        let StarlyCardCollectionProviderPrivatePath = /private/starlyCardCollectionProvider
        if !signer.getCapability<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>(StarlyCardCollectionProviderPrivatePath)!.check() {
            signer.link<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>(StarlyCardCollectionProviderPrivatePath, target: StarlyCard.CollectionStoragePath)
        }

        let starlyCardCollection = signer.getCapability<&StarlyCard.Collection{NonFungibleToken.Provider, StarlyCard.StarlyCardCollectionPublic}>(StarlyCardCollectionProviderPrivatePath)!
        assert(starlyCardCollection.borrow() != nil, message: "Missing or mis-typed StarlyCardCollection provider")

        let marketCollection = signer.borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath)
            ?? panic("Missing or mis-typed StarlyCardMarket Collection")

        let sellerFUSDVault = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(sellerFUSDVault.borrow() != nil, message: "Missing or mis-typed seller FUSD receiver")

        let beneficiary = getAccount(beneficiaryAddress);
        let beneficiaryFUSDVault = beneficiary.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(beneficiaryFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (beneficiary)")

        let creator = getAccount(creatorAddress)
        let creatorFUSDVault = creator.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(creatorFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (creator)")

        assert(beneficiaryCutPercent + creatorCutPercent < 1.0, message: "Sum of beneficiaryCutPercent and creatorCutPercent should be below 1.0")

        let sellerCutPercent = 1.0 - beneficiaryCutPercent - creatorCutPercent;
        let offer <- StarlyCardMarket.createSaleOffer (
            itemID: itemID,
            starlyID: starlyCardCollection.borrow()!.borrowStarlyCard(id: itemID)!.starlyID,
            price: price,
            sellerItemProvider: starlyCardCollection,
            sellerSaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: sellerFUSDVault,
                percent: sellerCutPercent),
            beneficiarySaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: beneficiaryFUSDVault,
                percent: beneficiaryCutPercent),
            creatorSaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: creatorFUSDVault,
                percent: creatorCutPercent),
            additionalSaleCutReceivers: [])
        marketCollection.insert(offer: <-offer)

        fun returnFlowFromStorage(_ storage: UInt64): UFix64 {
            let f = UFix64(storage % 100000000 as UInt64) * 0.00000001 as UFix64 + UFix64(storage / 100000000 as UInt64)
            let storageMb = f * 100.0 as UFix64
            let storage = FlowStorageFees.storageCapacityToFlow(storageMb)
            return storage
        }

        var storageUsed = returnFlowFromStorage(signer.storageUsed)
        var storageTotal = returnFlowFromStorage(signer.storageCapacity)
        if (storageUsed > storageTotal) {
            let difference = storageUsed - storageTotal
            let vaultRef = admin.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ?? panic("Could not borrow reference to the admin's Vault!")
            let sentVault <- vaultRef.withdraw(amount: difference)
            let receiver = signer.getCapability(/public/flowTokenReceiver).borrow<&{FungibleToken.Receiver}>()
                ?? panic("failed to borrow reference to recipient vault")
            receiver.deposit(from: <-sentVault)
        }
    }
}
