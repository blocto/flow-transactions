import FungibleToken from 0xf233dcee88fe0abe
import FUSD from 0x3c5959b568896393
import Profile from 0x097bafa4e0b48eef
import FIND from 0x097bafa4e0b48eef

transaction(name: String, amount: UFix64) {
	prepare(acct: AuthAccount) {

		let profileCap = acct.getCapability<&{Profile.Public}>(Profile.publicPath)

		let price=FIND.calculateCost(name)
		if amount != price {
			panic("expected renew cost is not the same as calculated renew cost")
		}
		let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow reference to the fusdVault!")
		let payVault <- vaultRef.withdraw(amount: price) as! @FUSD.Vault

		let finLeases= acct.borrow<&FIND.LeaseCollection>(from:FIND.LeaseStoragePath)!
		let finToken= finLeases.borrow(name)
		finToken.extendLease(<- payVault)
	}
}