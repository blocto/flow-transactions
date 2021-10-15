import FungibleToken from 0xf233dcee88fe0abe
import TeleportedTetherToken from 0xcfdd90d4a00f7b5b

transaction(amount: UFix64, target: String) {

    // The TeleportUser reference to send tokens to
    let teleportUserRef: &TeleportedTetherToken.TeleportAdmin{TeleportedTetherToken.TeleportUser}

    // The Vault resource that holds the tokens that are being transferred
    let sentVault: @FungibleToken.Vault

    prepare(signer: AuthAccount) {

        // Get a reference to the TeleportUser reference
        self.teleportUserRef = getAccount(0x55ad22f01ef568a1).getCapability(/public/teleportedTetherTokenTeleportUser)!
            .borrow<&TeleportedTetherToken.TeleportAdmin{TeleportedTetherToken.TeleportUser}>()
            ?? panic("Could not borrow a reference to TeleportUser")

        // Get a reference to the signer's stored vault
        let vaultRef = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath)
            ?? panic("Could not borrow a reference to the vault resource")

        // Withdraw tokens from the signer's stored vault
        self.sentVault <- vaultRef.withdraw(amount: amount);
    }

    execute {

        // Teleport the tokens
        self.teleportUserRef.teleportOut(from: <- self.sentVault, to: target.decodeHex())
    }
}