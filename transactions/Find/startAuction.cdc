import FIND from 0xFIND_ADDRESS

transaction(name: String) {
	prepare(account: AuthAccount) {

		let finLeases= account.borrow<&FIND.LeaseCollection>(from:FIND.LeaseStoragePath)!
		finLeases.startAuction(name)

	}
}

