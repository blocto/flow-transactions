import MikoSeaMarket from 0x0b80e42aaab305f0
import MIKOSEANFT from 0x0b80e42aaab305f0
import MIKOSEANFTV2 from 0x0b80e42aaab305f0
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448

pub fun getStorefront(_ account: AuthAccount): &MikoSeaMarket.Storefront {
    if let storefrontRef = account.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) {
        return storefrontRef
    } else {
        let storefront <- MikoSeaMarket.createStorefront()

        let storefrontRef = &storefront as &MikoSeaMarket.Storefront

        account.save(<-storefront, to: MikoSeaMarket.MarketStoragePath)

        account.link<&MikoSeaMarket.Storefront{MikoSeaMarket.StorefrontPublic}>(MikoSeaMarket.MarketPublicPath, target: MikoSeaMarket.MarketStoragePath)

        return storefrontRef
    }
}

transaction(listingID: UInt64) {
    let storefrontRef: &MikoSeaMarket.Storefront

    prepare(account: AuthAccount) {
        // check and remove storefront
        self.storefrontRef = getStorefront(account)
    }

    execute {
        self.storefrontRef.removeOrder(listingID)
    }
}