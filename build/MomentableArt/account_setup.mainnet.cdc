import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448
import NiftoryNonFungibleToken from 0x7ec1f607f0872a9e
import NiftoryNFTRegistry from 0x7ec1f607f0872a9e
import MomentableArt from 0x6b91adebfde2bec2

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