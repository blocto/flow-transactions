- Arguments: [0xfdf3785d97a2eece, 01J7A8DAW9W47V0MV8415P4P0K, 01J6ZHG14ZG1G6J4MW2DHR9P1B, 95932, 1, price,1500,currency,JPY, 3b95b13d1ddf9b877fbae7a98b58d36f48b66a220795db11ded7b04ab2639fca775a5ef1d75af0f92603a42159a7a994f9bcb6b85ff14007339dcd8529585d14, 10]

import NonFungibleToken from 0x1d7e57aa55817448
import FanTopToken from 0x86185fba578bc773
import FanTopPermissionV2a from 0x86185fba578bc773

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