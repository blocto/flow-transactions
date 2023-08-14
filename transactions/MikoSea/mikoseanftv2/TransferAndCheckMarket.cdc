import MIKOSEANFTV2 from 0xMIKOSEA_MIKOSEANFTV2_ADDRESS
import MikoSeaMarket from 0xMIKOSEA_MARKET_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS

pub fun checkMarket(acct: AuthAccount, nftID: UInt64) {
    if let storefrontRef = acct.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) {
        for order in storefrontRef.getOrders() {
            if order.nftType == Type<@MIKOSEANFTV2.NFT>() && order.nftID == nftID && (order.status == "created" || order.status == "validated") {
                panic("NFT_IS_IN_LISTING")
            }
        }
    }
}
transaction(nftID: UInt64, recipient: Address) {
    let holder: &MIKOSEANFTV2.Collection
    let recipientRef: &AnyResource{MIKOSEANFTV2.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.holder = signer.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) ?? panic("NOT_SETUP")

        self.recipientRef = getAccount(recipient).getCapability<&{MIKOSEANFTV2.CollectionPublic}>(MIKOSEANFTV2.CollectionPublicPath).borrow() ?? panic("NOT_SETUP")
        checkMarket(acct: signer, nftID: nftID)
    }

    execute {
        self.holder.transfer(nftID: nftID, recipient: self.recipientRef)
    }
}
