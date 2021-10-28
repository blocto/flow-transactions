import FIND from 0xFIND_ADDRESS

transaction(owner: Address, name: String) {
	prepare(account: AuthAccount) {

		let leaseCollection = getAccount(owner).getCapability<&FIND.LeaseCollection{FIND.LeaseCollectionPublic}>(FIND.LeasePublicPath)
		leaseCollection.borrow()!.fullfillAuction(name)

	}
}

