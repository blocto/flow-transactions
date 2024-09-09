import NonFungibleToken from 0x631e88ae7f1d7c20
import FanTopToken from 0x0
import FanTopPermissionV2a from 0x0

transaction(
  agent: Address,
  orderId: String,
  refId: String,
  nftId: UInt64,
  version: UInt32,
  metadata: [String],
  signature: String,
  keyIndex: Int
) {
  let capability: Capability<auth(NonFungibleToken.Withdraw) &FanTopToken.Collection>
  let user: FanTopPermissionV2a.User

  prepare(account: auth(IssueStorageCapabilityController) &Account) {
    self.user = FanTopPermissionV2a.User()
    let capability = account.capabilities.storage.issue<auth(NonFungibleToken.Withdraw) &FanTopToken.Collection>(FanTopToken.collectionStoragePath)
    if !capability.check() {
      panic("Invalid capability")
    }
    self.capability = capability
  }

  execute {
    self.user.sell(
      agent: agent,
      capability: self.capability,
      orderId: orderId,
      refId: refId,
      nftId: nftId,
      version: version,
      metadata: metadata,
      signature: signature.decodeHex(),
      keyIndex: keyIndex
    )
  }
}