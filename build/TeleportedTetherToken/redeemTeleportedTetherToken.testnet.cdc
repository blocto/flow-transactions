import FungibleToken from 0x9a0766d93b6608b7
import TeleportedTetherToken from 0xab26e0a07d770ec1

transaction() {
  prepare(signer: auth(BorrowValue) &Account) {
    let targetAddress: String = "0xffff....ffff" // NOTE: REPLACE with the target ethereum address

    let teleportUserRef = getAccount(0xf086a545ce3c552d).capabilities
        .borrow<&{TeleportedTetherToken.TeleportUser}>(/public/teleportedTetherTokenTeleportUser)
        ?? panic("Could not borrow a reference to TeleportUser")

    let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &TeleportedTetherToken.Vault>(from: /storage/teleportedTetherTokenVault)
        ?? panic("Could not borrow a reference to the vault resource")

    let vault <- vaultRef.withdraw(amount: vaultRef.balance);

    teleportUserRef.teleportOut(from: <- vault, to: targetAddress.replaceAll(of: "0x", with: "").decodeHex())
  }
}