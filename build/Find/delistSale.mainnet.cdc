import FIND from 0x097bafa4e0b48eef

transaction(name: String) {
	prepare(acct: AuthAccount) {
		let finLeases= acct.borrow<&FIND.LeaseCollection>(from:FIND.LeaseStoragePath)!
		finLeases.delistSale(name)
	}
}