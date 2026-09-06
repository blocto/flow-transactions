import FungibleToken from 0xf233dcee88fe0abe
import TeleportedTetherToken from 0xcfdd90d4a00f7b5b

transaction() {
  prepare(signer: auth(BorrowValue) &Account) {
    let targetAddress: String = "0xffff....ffff" // NOTE: REPLACE with the target ethereum address

    let teleportUserRef = getAccount(0x55ad22f01ef568a1).capabilities
        .borrow<&{TeleportedTetherToken.TeleportUser}>(/public/teleportedTetherTokenTeleportUser)
        ?? panic("Could not borrow a reference to TeleportUser")

    let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &TeleportedTetherToken.Vault>(from: /storage/teleportedTetherTokenVault)
        ?? panic("Could not borrow a reference to the vault resource")

    let vault <- vaultRef.withdraw(amount: vaultRef.balance);

    teleportUserRef.teleportOut(from: <- vault, to: targetAddress.replaceAll(of: "0x", with: "").decodeHex())
  }
}