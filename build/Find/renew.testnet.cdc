import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import Profile from 0x37a05b1ecacc80f7
import FIND from 0x37a05b1ecacc80f7

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