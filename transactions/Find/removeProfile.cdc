import Profile from 0xVERSUS_ADDRESS
import FIND from 0xFIND_ADDRESS

transaction() {
	prepare(acct: AuthAccount) {
			acct.unlink(Profile.publicPath)
			destroy <- acct.load<@AnyResource>(from:Profile.storagePath)

			acct.unlink(FIND.BidPublicPath)
			destroy <- acct.load<@AnyResource>(from:FIND.BidStoragePath)

			acct.unlink(FIND.LeasePublicPath)
			destroy <- acct.load<@AnyResource>(from:FIND.LeaseStoragePath)
	}
}

