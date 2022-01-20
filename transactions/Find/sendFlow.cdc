import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import FIND from 0xFIND_ADDRESS
import CharityNFT from 0xFIND_ADDRESS

transaction(name: String, amount: UFix64) {

	prepare(account: AuthAccount) {
		let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ?? panic("Could not borrow reference to the fusdVault!")
		FIND.deposit(to: name, from: <- vaultRef.withdraw(amount: amount))
	}
}
