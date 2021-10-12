import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
transaction(amount: UFix64) {
    let sentVault: @FungibleToken.Vault
    prepare(signer: AuthAccount) {
        let vaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow reference to the owner's Vault!")
        self.sentVault <- vaultRef.withdraw(amount: amount)
    }
    execute {
        let recipient = getAccount(0x1f56a1e665826a52)
        let receiverRef = recipient.getCapability(/public/flowTokenReceiver)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Could not borrow receiver reference to the recipient's Vault")
        receiverRef.deposit(from: <-self.sentVault)
    }
}
