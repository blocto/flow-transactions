import FUSD from 0xe223d8a629e49c68
import NonFungibleToken from 0x631e88ae7f1d7c20
import FIND from 0x37a05b1ecacc80f7
import CharityNFT from 0x37a05b1ecacc80f7

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