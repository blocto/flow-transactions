import FanTopToken from 0xFANTOP_ADDRESS

transaction {
  prepare(acct: AuthAccount) {
    if acct.borrow<&FanTopToken.Collection>(from: FanTopToken.collectionStoragePath) != nil {
      if (!getAccount(acct.address).getCapability<&{FanTopToken.CollectionPublic}>(FanTopToken.collectionPublicPath).check()) {
        panic("Collection check failed.")
      }
      return;
    }

    let collection <- FanTopToken.createEmptyCollection() as! @FanTopToken.Collection
    acct.save(<-collection, to: FanTopToken.collectionStoragePath)
    acct.link<&{FanTopToken.CollectionPublic}>(FanTopToken.collectionPublicPath, target: FanTopToken.collectionStoragePath)
  }
}