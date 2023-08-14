import MikoSeaMarket from 0xMIKOSEA_MARKET_ADDRESS
import MIKOSEANFT from 0xMIKOSEA_MIKOSEANFT_ADDRESS
import MIKOSEANFTV2 from 0xMIKOSEA_MIKOSEANFTV2_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import MetadataViews from 0xMETADATA_VIEWS_ADDRESS

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