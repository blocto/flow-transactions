import FIND from 0x85f0d6217184009b
import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68

transaction(name: String, amount: UFix64) {
	prepare(account: AuthAccount) {

		let vaultRef = account.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow reference to the owner's Vault!")
		 
		let fusdReceiver = account.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)

		let leaseCollection = account.getCapability<&FIND.LeaseCollection{FIND.LeaseCollectionPublic}>(FIND.LeasePublicPath)
		if !leaseCollection.check() {
			account.unlink(FIND.LeasePublicPath)
			destroy <- account.load<@AnyResource>(from:FIND.LeaseStoragePath)
			account.save(<- FIND.createEmptyLeaseCollection(), to: FIND.LeaseStoragePath)
			account.link<&FIND.LeaseCollection{FIND.LeaseCollectionPublic}>( FIND.LeasePublicPath, target: FIND.LeaseStoragePath)
		}

		let bidCollection = account.getCapability<&FIND.BidCollection{FIND.BidCollectionPublic}>(FIND.BidPublicPath)
		if !bidCollection.check() {
			account.unlink(FIND.BidPublicPath)
			destroy <- account.load<@AnyResource>(from:FIND.BidStoragePath)
			account.save(<- FIND.createEmptyBidCollection(receiver: fusdReceiver, leases: leaseCollection), to: FIND.BidStoragePath)
			account.link<&FIND.BidCollection{FIND.BidCollectionPublic}>( FIND.BidPublicPath, target: FIND.BidStoragePath)
		}

		let vault <- vaultRef.withdraw(amount: amount) as! @FUSD.Vault
		let bids = account.borrow<&FIND.BidCollection>(from: FIND.BidStoragePath)!
		bids.bid(name: name, vault: <- vault)

	}
}