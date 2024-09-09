import NonFungibleToken from 0x631e88ae7f1d7c20
import FanTopToken from 0x0

transaction(id: UInt64, to: Address) {
  let transferToken: @FanTopToken.NFT

  prepare(from: auth(BorrowValue) &Account) {
    let fromRef = from.storage.borrow<auth(NonFungibleToken.Withdraw) &FanTopToken.Collection>(from: FanTopToken.collectionStoragePath)!
    self.transferToken <- fromRef.withdraw(withdrawID: id) as! @FanTopToken.NFT
  }

  execute {
    let toRef = getAccount(to).capabilities.borrow<&{FanTopToken.CollectionPublic}>(FanTopToken.collectionPublicPath)!
    toRef.deposit(token: <- self.transferToken)
  }
}