import AFLAdmin from 0x8f9231920da9af6d
import AFLPack from 0x8f9231920da9af6d
import FungibleToken from 0xf233dcee88fe0abe
import FiatToken from 0xb19436aae4d94622

transaction(templateIds: [UInt64], packTemplateId: UInt64, price:UFix64, receiptAddress: Address) {
  let adminRef: &AFLPack.Pack
  let temporaryVault : @FungibleToken.Vault
  prepare(adminAccount: AuthAccount, tokenRecipientAccount: AuthAccount){
      self.adminRef = adminAccount.borrow<&AFLPack.Pack>(from: AFLPack.PackStoragePath)
          ??panic("could not borrow admin reference")
      let vaultRef = tokenRecipientAccount.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
              ??panic("could not borrow vault")
      self.temporaryVault <- vaultRef.withdraw(amount: price)
  }
  execute{
      self.adminRef.buyPack(templateIds: templateIds, packTemplateId: packTemplateId, receiptAddress: receiptAddress, price: price, flowPayment: <- self.temporaryVault)
  }
}