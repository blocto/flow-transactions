import MikoSeaMarket from 0x713306ac51ac7ddb
import MIKOSEANFT from 0x713306ac51ac7ddb
import MIKOSEANFTV2 from 0x713306ac51ac7ddb
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

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