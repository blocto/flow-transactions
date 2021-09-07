import StarlyCardMarket from 0x697d72a988a77070

transaction(itemID: UInt64) {
    prepare(account: AuthAccount) {
        let offer <- account
          .borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath)!
          .remove(itemID: itemID)
        destroy offer
    }
}
