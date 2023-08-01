import FanTopToken from 0xFANTOP_ADDRESS
import FanTopPermissionV2a from 0xFANTOP_ADDRESS

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
  let capability: Capability<&FanTopToken.Collection>
  let user: FanTopPermissionV2a.User

  prepare(account: AuthAccount) {
    self.user = FanTopPermissionV2a.User()
    var capability = account.getCapability<&FanTopToken.Collection>(/private/FanTopTokenCollection)
    if !capability.check() {
      capability = account.link<&FanTopToken.Collection>(/private/FanTopTokenCollection, target:/storage/FanTopTokenCollection) ?? panic("Link failed")
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