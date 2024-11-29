import TheFabricantMarketplace from 0xTheFabricantMarketplace

transaction(listingID: String) {

    let listingRef: &TheFabricantMarketplace.Listings

    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's listing collection
        self.listingRef = acct.borrow<&TheFabricantMarketplace.Listings>(from: TheFabricantMarketplace.ListingsStoragePath)
            ?? panic("Could not borrow from listings in storage")
    }

    execute {
    
        // de-listing item
        self.listingRef.removeListing(listingID: listingID)

    }
}  