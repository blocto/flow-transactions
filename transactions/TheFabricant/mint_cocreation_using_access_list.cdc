import TheFabricantKapers from 0xTheFabricantKapers
import MetadataViews from 0xMetadataViews
import NonFungibleToken from 0xNonFungibleToken
import TheFabricantNFTStandardV2 from 0xTheFabricantNFTStandardV2
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken

transaction(
    publicMinterAddress: Address,
    publicMinterPathString: String,
    garmentId: UInt64,
    materialId: UInt64,
    primaryColorId: UInt64, 
    secondaryColorId: UInt64,

    ){
    let publicMinter: &TheFabricantKapers.PublicMinter{TheFabricantKapers.Minter}
    let receiver: &TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic}
    let payment: @FungibleToken.Vault

    prepare(acct: AuthAccount) {
        // Create public path
        let publicPath = PublicPath(identifier: publicMinterPathString)
            ?? panic("Couldn't construct publicMinter public path")
        
        // Set public minter
        // If it fails here, it's likely that the publicMinterAddress path in the tx is wrong
        self.publicMinter = getAccount(publicMinterAddress)
            .getCapability(publicPath).borrow<&TheFabricantKapers.PublicMinter{TheFabricantKapers.Minter}>() 
            ?? panic("Couldn't get publicMinter ref or publicMinterPathString is wrong: ".concat(publicMinterPathString))
        
        // Set receiver
        if !(acct.getCapability<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantKapers.TheFabricantKapersCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath).check()) {
            if acct.type(at: TheFabricantKapers.TheFabricantKapersCollectionStoragePath) == nil {
                let collection <- TheFabricantKapers.createEmptyCollection() as! @TheFabricantKapers.Collection
                acct.save(<- collection, to: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
            }
            acct.unlink(TheFabricantKapers.TheFabricantKapersCollectionPublicPath)

            acct.link<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantKapers.TheFabricantKapersCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath, target: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
        } 

        // Get receiver
        self.receiver = acct.getCapability<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath).borrow() 
            ?? panic("Couldn't get receiver")
        
        // Collect payment
        let vaultRef: &FlowToken.Vault{FungibleToken.Provider} = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")
        let paymentAmount = self.publicMinter.getPublicMinterDetails()["paymentAmount"]!
        var amount = paymentAmount as! UFix64

        // If free mint is active, withdraw 0 Flow
        if (TheFabricantKapers.getIsFreeMintActive() == true) {
            amount = 0.0
        }
        
        log("amount")
        log(amount)
        self.payment <- vaultRef.withdraw(amount: amount)
        
    }
    // have to make the payment optional...
    execute {
        self.publicMinter.mintUsingAccessList(
            receiver: self.receiver, 
            payment: <- self.payment,
            garmentId: garmentId,
            materialId: materialId,
            primaryColorId: primaryColorId,
            secondaryColorId: secondaryColorId
        )
    }
}