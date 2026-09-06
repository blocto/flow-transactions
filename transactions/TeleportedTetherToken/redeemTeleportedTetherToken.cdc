import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import TeleportedTetherToken from 0xTELEPORTED_USDT_ADDRESS

transaction() {
  prepare(signer: auth(BorrowValue) &Account) {
    let targetAddress: String = "0xffff....ffff" // NOTE: REPLACE with the target ethereum address

    let teleportUserRef = getAccount(0xTELEPORT_ADMIN_ADDRESS).capabilities
        .borrow<&{TeleportedTetherToken.TeleportUser}>(/public/teleportedTetherTokenTeleportUser)
        ?? panic("Could not borrow a reference to TeleportUser")

    let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &TeleportedTetherToken.Vault>(from: /storage/teleportedTetherTokenVault)
        ?? panic("Could not borrow a reference to the vault resource")

    let vault <- vaultRef.withdraw(amount: vaultRef.balance);

    teleportUserRef.teleportOut(from: <- vault, to: targetAddress.replaceAll(of: "0x", with: "").decodeHex())
  }
}