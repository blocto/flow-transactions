import FungibleToken from 0xf233dcee88fe0abe
import LockedTokens from 0x8d0e87b65159ae63
import FlowToken from 0x1654653399040a61
import FlowStorageFees from 0xe467b9dd11fa00df
import BloctoStorageRent from 0x1dfd1e5b87b847dc
import FlowIDTableStaking from 0x8624b52f9ddcd04a

transaction(id: String, amount: UFix64, cosignerPubKey: String) {

  let holderRef: &LockedTokens.TokenHolder
  
  let vaultRef: &FlowToken.Vault

  prepare(custodyProvider: AuthAccount, userAccount: AuthAccount) {

    let sharedAccount = AuthAccount(payer: custodyProvider)

    // Add a key
    sharedAccount.keys.add(
      publicKey: PublicKey(
          publicKey: cosignerPubKey.decodeHex(),
          signatureAlgorithm: SignatureAlgorithm.ECDSA_secp256k1
      ),
      hashAlgorithm: HashAlgorithm.SHA3_256,
      weight: 1000.0
    )

    let vaultCapability = sharedAccount.link<&FlowToken.Vault>(
      /private/flowTokenVault, 
      target: /storage/flowTokenVault
    ) ?? panic("Could not link Flow Token Vault capability")

    let lockedTokenManager <- LockedTokens.createLockedTokenManager(vault: vaultCapability)

    sharedAccount.save(<-lockedTokenManager, to: LockedTokens.LockedTokenManagerStoragePath)

    let tokenManagerCapability = sharedAccount.link<&LockedTokens.LockedTokenManager>(
      LockedTokens.LockedTokenManagerPrivatePath, 
      target: LockedTokens.LockedTokenManagerStoragePath
    ) ?? panic("Could not link token manager capability")

    let tokenHolder <- LockedTokens.createTokenHolder(
      lockedAddress: sharedAccount.address, 
      tokenManager: tokenManagerCapability
    )

    userAccount.save(<-tokenHolder, to: LockedTokens.TokenHolderStoragePath)

    userAccount.link<&LockedTokens.TokenHolder{LockedTokens.LockedAccountInfo}>(
      LockedTokens.LockedAccountInfoPublicPath, 
      target: LockedTokens.TokenHolderStoragePath
    )

    let tokenAdminCapability = sharedAccount.link<&LockedTokens.LockedTokenManager>(
      LockedTokens.LockedTokenAdminPrivatePath, 
      target: LockedTokens.LockedTokenManagerStoragePath
    ) ?? panic("Could not link token custodyProvider to token manager")

    let lockedAccountCreator = custodyProvider.borrow<&LockedTokens.LockedAccountCreator>(
      from: LockedTokens.LockedAccountCreatorStoragePath
    ) ?? panic("Could not borrow reference to LockedAccountCreator")

    lockedAccountCreator.addAccount(
      sharedAccountAddress: sharedAccount.address, 
      unlockedAccountAddress: userAccount.address, 
      tokenAdmin: tokenAdminCapability
    )

    // Override the default FlowToken receiver
    sharedAccount.unlink(/public/flowTokenReceiver)

    // create new receiver that marks received tokens as unlocked
    sharedAccount.link<&AnyResource{FungibleToken.Receiver}>(
      /public/flowTokenReceiver, 
      target: LockedTokens.LockedTokenManagerStoragePath
    )

    // pub normal receiver in a separate unique path
    sharedAccount.link<&AnyResource{FungibleToken.Receiver}>(
      /public/lockedFlowTokenReceiver, 
      target: /storage/flowTokenVault
    )

    BloctoStorageRent.tryRefill(custodyProvider.address)
    BloctoStorageRent.tryRefill(userAccount.address)

    self.holderRef = userAccount.borrow<&LockedTokens.TokenHolder>(
      from: LockedTokens.TokenHolderStoragePath
    ) ?? panic("TokenHolder is not saved at specified path")
    
    self.vaultRef = userAccount.borrow<&FlowToken.Vault>(
      from: /storage/flowTokenVault
    ) ?? panic("Could not borrow flow token vault reference")
  }

  execute {
    let lockedBalance = self.holderRef.getLockedAccountBalance()

    if amount <= lockedBalance {
      self.holderRef.createNodeDelegator(nodeID: id)
      let stakerProxy = self.holderRef.borrowDelegator()
      stakerProxy.delegateNewTokens(amount: amount - FlowIDTableStaking.getDelegatorMinimumStakeRequirement())
    } else if ((amount - lockedBalance) <= (self.vaultRef.balance - FlowStorageFees.minimumStorageReservation)) {
      self.holderRef.deposit(from: <-self.vaultRef.withdraw(amount: amount - lockedBalance))
      self.holderRef.createNodeDelegator(nodeID: id)
      let stakerProxy = self.holderRef.borrowDelegator()
      stakerProxy.delegateNewTokens(amount: amount - FlowIDTableStaking.getDelegatorMinimumStakeRequirement())
    } else {
      panic("Not enough tokens to stake!")
    }
  }
}