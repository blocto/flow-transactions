import TheFabricantPrimalRave from 0xTheFabricantPrimalRave
import MetadataViews from 0xMetadataViews
import NonFungibleToken from 0xNonFungibleToken
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken


transaction(
    publicMinterAddress: Address,
    publicMinterPathString: String,
    variantId: UInt64

    ){
    let publicMinter: &TheFabricantPrimalRave.PublicMinter{TheFabricantPrimalRave.Minter}
    let receiver: &TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic}
    let payment: @FungibleToken.Vault

    prepare(acct: AuthAccount) {
        // Create public path
        let publicPath = PublicPath(identifier: publicMinterPathString)
            ?? panic("Couldn't construct publicMinter public path")
        
        // Set public minter
        // If it fails here, it's likely that the publicMinterAddress path in the tx is wrong
        self.publicMinter = getAccount(publicMinterAddress)
            .getCapability(publicPath).borrow<&TheFabricantPrimalRave.PublicMinter{TheFabricantPrimalRave.Minter}>() 
            ?? panic("Couldn't get publicMinter ref or publicMinterPathString is wrong: ".concat(publicMinterPathString))
        
        // Set receiver
        if !(acct.getCapability<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath).check()) {
            if acct.type(at: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath) == nil {
                let collection <- TheFabricantPrimalRave.createEmptyCollection() as! @TheFabricantPrimalRave.Collection
                acct.save(<- collection, to: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
            }
            acct.unlink(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath)

            acct.link<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath, target: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
        } 
        self.receiver = acct.getCapability<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath).borrow() 
            ?? panic("Couldn't get receiver")
        
        let vaultRef: &FlowToken.Vault{FungibleToken.Provider} = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")
        let paymentAmount = ${paymentAmountVariable}
        let amount = paymentAmount as! UFix64
        log("amount")
        log(amount)
        self.payment <- vaultRef.withdraw(amount: amount)
        
    }
 
    execute {
        self.publicMinter.mintUsingAccessList(
            receiver: self.receiver, 
            payment: <- self.payment,
            variantId: variantId
        )
    }
}