import FUSD from 0x3c5959b568896393
import NonFungibleToken from 0x1d7e57aa55817448
import FIND from 0x097bafa4e0b48eef
import CharityNFT from 0x097bafa4e0b48eef

transaction(name: String, amount: UFix64, type: String) {

	prepare(account: AuthAccount) {

		let vaultRef = account.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow reference to the fusdVault!")
		FIND.deposit(to: name, from: <- vaultRef.withdraw(amount: amount))
	}

}