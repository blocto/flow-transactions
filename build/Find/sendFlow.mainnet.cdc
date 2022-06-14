import NonFungibleToken from 0x1d7e57aa55817448
import FlowToken from 0x1654653399040a61
import FIND from 0x097bafa4e0b48eef
import CharityNFT from 0x097bafa4e0b48eef

transaction(name: String, amount: UFix64) {

	prepare(account: AuthAccount) {
		let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ?? panic("Could not borrow reference to the fusdVault!")
		FIND.deposit(to: name, from: <- vaultRef.withdraw(amount: amount))
	}
}