import AFLAdmin from 0xb39a42479c1c2c77
import AFLPack from 0xb39a42479c1c2c77
import FungibleToken from 0x9a0766d93b6608b7
import FiatToken from 0xa983fecbed621163

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