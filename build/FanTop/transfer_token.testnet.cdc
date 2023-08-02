import FanTopToken from 0x0

transaction(id: UInt64, to: Address) {
  let transferToken: @FanTopToken.NFT

  prepare(from: AuthAccount) {
    let fromRef = from.borrow<&FanTopToken.Collection>(from: FanTopToken.collectionStoragePath)!
    self.transferToken <- fromRef.withdraw(withdrawID: id) as! @FanTopToken.NFT
  }

  execute {
    let toRef = getAccount(to).getCapability(FanTopToken.collectionPublicPath).borrow<&{FanTopToken.CollectionPublic}>()!
    toRef.deposit(token: <- self.transferToken)
  }
}