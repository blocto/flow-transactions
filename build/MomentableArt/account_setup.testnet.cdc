import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import NiftoryNonFungibleToken from 0x04f74f0252479aed
import NiftoryNFTRegistry from 0x04f74f0252479aed
import MomentableArt from 0x2d44e28d37b3468d

transaction(storageAddress: Address,clientInfo: String) {
    prepare(acct: AuthAccount) {
        let paths = NiftoryNFTRegistry.getCollectionPaths(storageAddress, clientInfo)

        if acct.borrow<&NonFungibleToken.Collection>(from: paths.storage) == nil {
            let nftManager = NiftoryNFTRegistry.getNFTManagerPublic(storageAddress, clientInfo)
            let collection <- nftManager.getNFTCollectionData().createEmptyCollection()
            acct.save(<-collection, to: paths.storage)

            acct.unlink(paths.public)
            acct.link<&{
                NonFungibleToken.Receiver,
                NonFungibleToken.CollectionPublic,
                MetadataViews.ResolverCollection,
                NiftoryNonFungibleToken.CollectionPublic
            }>(paths.public, target: paths.storage)

            acct.unlink(paths.private)
            acct.link<&{
                NonFungibleToken.Provider,
                NiftoryNonFungibleToken.CollectionPrivate
            }>(paths.private, target: paths.storage)
        }
    }
}