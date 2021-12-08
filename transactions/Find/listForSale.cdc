import FIND from 0xFIND_ADDRESS

transaction(name: String, directSellPrice:UFix64) {
	prepare(acct: AuthAccount) {
		let finLeases= acct.borrow<&FIND.LeaseCollection>(from:FIND.LeaseStoragePath)!
		finLeases.listForSale(name: name,  directSellPrice:directSellPrice)
	}
}

