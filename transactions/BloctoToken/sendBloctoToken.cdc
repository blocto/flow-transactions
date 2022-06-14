import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import BloctoToken from 0xBLOCTO_TOKEN_ADDRESS

transaction(amount: UFix64, to: Address) {
    let sentVault: @FungibleToken.Vault
    prepare(signer: AuthAccount) {
        let vaultRef = signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault)
            ?? panic("Could not borrow reference to the owner's Vault!")
        self.sentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        let recipient = getAccount(to)
        let receiverRef = recipient.getCapability(/public/bloctoTokenReceiver)!.borrow<&{FungibleToken.Receiver}>()
            ?? panic("Could not borrow receiver reference to the recipient's Vault")
        receiverRef.deposit(from: <-self.sentVault)
    }
}