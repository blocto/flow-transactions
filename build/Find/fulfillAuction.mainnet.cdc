import FIND from 0x097bafa4e0b48eef

transaction(owner: Address, name: String) {
	prepare(account: AuthAccount) {

		let leaseCollection = getAccount(owner).getCapability<&FIND.LeaseCollection{FIND.LeaseCollectionPublic}>(FIND.LeasePublicPath)
		leaseCollection.borrow()!.fulfillAuction(name)

	}
}