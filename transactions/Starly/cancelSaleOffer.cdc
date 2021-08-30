import StarlyCardMarket from 0xSTARLY_CARD_MARKET_ADDRESS

transaction(itemID: UInt64) {
    prepare(account: AuthAccount) {
        let offer <- account
          .borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath)!
          .remove(itemID: itemID)
        destroy offer
    }
}
