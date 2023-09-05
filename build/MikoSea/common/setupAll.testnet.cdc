import MIKOSEANFT from 0x713306ac51ac7ddb
import MIKOSEANFTV2 from 0x713306ac51ac7ddb
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

transaction {
    prepare(signer: AuthAccount) {
        // for MIKOSAENFTV2
        if signer.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) == nil {
            let collection <- MIKOSEANFTV2.createEmptyCollection()
            signer.save(<-collection, to: MIKOSEANFTV2.CollectionStoragePath)
        }
        if (signer.getCapability<&MIKOSEANFTV2.Collection{MIKOSEANFTV2.CollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFTV2.CollectionPublicPath).borrow() == nil) {
            signer.unlink(MIKOSEANFTV2.CollectionPublicPath)
            signer.link<&MIKOSEANFTV2.Collection{MIKOSEANFTV2.CollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFTV2.CollectionPublicPath, target: MIKOSEANFTV2.CollectionStoragePath)
        }

        // for MIKOSAENFT
        if signer.borrow<&MIKOSEANFT.Collection>(from: MIKOSEANFT.CollectionStoragePath) == nil {
            let collection <- MIKOSEANFT.createEmptyCollection()
            signer.save(<-collection, to: MIKOSEANFT.CollectionStoragePath)
        }
        if (signer.getCapability<&MIKOSEANFT.Collection{MIKOSEANFT.MikoSeaCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFT.CollectionPublicPath).borrow() == nil) {
            signer.unlink(MIKOSEANFT.CollectionPublicPath)
            signer.link<&MIKOSEANFT.Collection{MIKOSEANFT.MikoSeaCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFT.CollectionPublicPath, target: MIKOSEANFT.CollectionStoragePath)
        }
    }
}