- Arguments: [95935, 0xd38c1fc1e906ffd0]

import NonFungibleToken from 0x1d7e57aa55817448
import FanTopToken from 0x86185fba578bc773

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