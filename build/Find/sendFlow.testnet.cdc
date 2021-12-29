import NonFungibleToken from 0x631e88ae7f1d7c20
import FlowToken from 0x7e60df042a9c0868
import FIND from 0x37a05b1ecacc80f7
import CharityNFT from 0x37a05b1ecacc80f7

transaction(name: String, amount: UFix64) {

	prepare(account: AuthAccount) {

		let charityCap = account.getCapability<&{NonFungibleToken.CollectionPublic}>(CharityNFT.CollectionPublicPath)

		if !charityCap.check() {
			account.save<@NonFungibleToken.Collection>(<- CharityNFT.createEmptyCollection(), to: CharityNFT.CollectionStoragePath)
			account.link<&{NonFungibleToken.CollectionPublic}>(CharityNFT.CollectionPublicPath, target: CharityNFT.CollectionStoragePath)
		}
		let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ?? panic("Could not borrow reference to the fusdVault!")
		FIND.deposit(to: name, from: <- vaultRef.withdraw(amount: amount))

	}

}