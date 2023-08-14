import MikoSeaMarket from "../../contracts/MikoSeaMarket.cdc"
import MIKOSEANFT from "../../contracts/MiKoSeaNFT.cdc"
import MIKOSEANFTV2 from "../../contracts/MIKOSEANFTV2.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

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