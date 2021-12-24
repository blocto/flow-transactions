import FUSD from 0x3c5959b568896393
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN
import FIND from 0x097bafa4e0b48eef
import CharityNFT from 0x097bafa4e0b48eef

transaction(name: String, amount: UFix64, type: String) {

	prepare(account: AuthAccount) {

		let charityCap = account.getCapability<&{NonFungibleToken.CollectionPublic}>(CharityNFT.CollectionPublicPath)

		if !charityCap.check() {
			account.save<@NonFungibleToken.Collection>(<- CharityNFT.createEmptyCollection(), to: CharityNFT.CollectionStoragePath)
			account.link<&{NonFungibleToken.CollectionPublic}>(CharityNFT.CollectionPublicPath, target: CharityNFT.CollectionStoragePath)
		}

		let vaultRef = account.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Could not borrow reference to the fusdVault!")
		FIND.deposit(to: name, from: <- vaultRef.withdraw(amount: amount))
	}

}