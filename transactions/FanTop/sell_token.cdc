import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
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