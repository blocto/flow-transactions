import FUSD from 0xFUSD_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import FIND from 0xFIND_ADDRESS
import CharityNFT from 0xFIND_ADDRESS

transaction(name: String, amount: UFix64, type: String) {

	prepare(account: AuthAccount) {

		let vaultRef = account.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow reference to the fusdVault!")
		FIND.deposit(to: name, from: <- vaultRef.withdraw(amount: amount))
	}

}
