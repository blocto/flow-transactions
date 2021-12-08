import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FlowStorageFees from 0xFLOW_STORAGE_FEES_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import StarlyCard from 0xSTARLY_CARD_ADDRESS
import StarlyCardMarket from 0xSTARLY_CARD_MARKET_ADDRESS

transaction(itemID: UInt64, marketCollectionAddress: Address) {
    prepare(signer: AuthAccount, admin: AuthAccount) {
        let marketCollection = getAccount(marketCollectionAddress)
            .getCapability<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(
                StarlyCardMarket.CollectionPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow market collection from market address")

        let saleItem = marketCollection.borrowSaleItem(itemID: itemID)
                    ?? panic("No item with that ID")
        let price = saleItem.price

        let mainFUSDVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        let paymentVault <- mainFUSDVault.withdraw(amount: price)

        let starlyCardCollection = signer.borrow<&StarlyCard.Collection{NonFungibleToken.Receiver}>(
            from: StarlyCard.CollectionStoragePath
        ) ?? panic("Cannot borrow StarlyCard collection receiver from acct")

        marketCollection.purchase(
            itemID: itemID,
            buyerCollection: starlyCardCollection,
            buyerPayment: <- paymentVault,
            buyerAddress: signer.address
        )

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
