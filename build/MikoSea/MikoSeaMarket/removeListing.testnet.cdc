// remove listing v3.0
import MikoSeaMarket from 0x713306ac51ac7ddb

transaction(listingID: UInt64) {
    let storefrontRef: &MikoSeaMarket.Storefront

    prepare(acct: auth(BorrowValue) &Account) {
        // check and remove storefront
        self.storefrontRef = acct.storage.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) ?? panic("Account not setup")
    }

    execute {
        self.storefrontRef.removeOrder(listingID)
    }
}