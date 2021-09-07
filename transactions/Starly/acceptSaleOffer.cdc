import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import StarlyCard from 0xSTARLY_CARD_ADDRESS
import StarlyCardMarket from 0xSTARLY_CARD_MARKET_ADDRESS

transaction(itemID: UInt64, marketCollectionAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let starlyCardCollection: &StarlyCard.Collection{NonFungibleToken.Receiver}
    let marketCollection: &StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}
    let buyerAddress: Address

    prepare(signer: AuthAccount) {
        self.buyerAddress = signer.address;
        self.marketCollection = getAccount(marketCollectionAddress)
            .getCapability<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(
                StarlyCardMarket.CollectionPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow market collection from market address")

        let saleItem = self.marketCollection.borrowSaleItem(itemID: itemID)
                    ?? panic("No item with that ID")
        let price = saleItem.price

        let mainFUSDVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.paymentVault <- mainFUSDVault.withdraw(amount: price)

        self.starlyCardCollection = signer.borrow<&StarlyCard.Collection{NonFungibleToken.Receiver}>(
            from: StarlyCard.CollectionStoragePath
        ) ?? panic("Cannot borrow StarlyCard collection receiver from acct")
    }

    execute {
        self.marketCollection.purchase(
            itemID: itemID,
            buyerCollection: self.starlyCardCollection,
            buyerPayment: <- self.paymentVault,
            buyerAddress: self.buyerAddress
        )
    }
}
