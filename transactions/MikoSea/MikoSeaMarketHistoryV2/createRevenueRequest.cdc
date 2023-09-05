// adminCreateRevenueRequest v1
import MikoSeaMarketHistoryV2 from 0xMIKOSEA_MARKET_ADDRESS

transaction(
        address: Address,
        amount: UFix64,
        metadata: {String:String}
    ) {
    let adminRef: &MikoSeaMarketHistoryV2.Admin
    prepare(admin: AuthAccount) {
        self.adminRef = admin.borrow<&MikoSeaMarketHistoryV2.Admin>(from: MikoSeaMarketHistoryV2.AdminStoragePath) ?? panic("NOT_ADMIN")
    }

    execute {
        self.adminRef.createRequestRevenue(address, amount: amount, metadata: metadata)
    }
}
