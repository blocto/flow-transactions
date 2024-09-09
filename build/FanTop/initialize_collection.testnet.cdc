import FanTopToken from 0x0

transaction {
  prepare(acct: auth(Storage, Capabilities) &Account) {
    if acct.storage.borrow<&FanTopToken.Collection>(from: FanTopToken.collectionStoragePath) != nil {
        panic("The account has already been initialized.")
    }

    let collection <- FanTopToken.createEmptyDefaultTypeCollection() as! @FanTopToken.Collection
    acct.storage.save(<-collection, to: FanTopToken.collectionStoragePath)
    let capability = acct.capabilities.storage.issue<&{FanTopToken.CollectionPublic}>(FanTopToken.collectionStoragePath)
    acct.capabilities.publish(capability, at: FanTopToken.collectionPublicPath)
  }
}