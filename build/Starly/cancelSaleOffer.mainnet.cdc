import StarlyCardMarket from 0x5b82f21c0edf76e3

transaction(itemID: UInt64) {
    prepare(account: AuthAccount) {
        let offer <- account
          .borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath)!
          .remove(itemID: itemID)
        destroy offer
    }
}
