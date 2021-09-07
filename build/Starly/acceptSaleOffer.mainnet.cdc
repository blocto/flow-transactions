import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import StarlyCard from 0x5b82f21c0edf76e3
import StarlyCardMarket from 0x5b82f21c0edf76e3

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
