import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import MetadataViews from 0xMETADATA_VIEWS_ADDRESS
import NiftoryNonFungibleToken from 0xNIFTORY_NON_FUNGIBLE_TOKEN_ADDRESS
import NiftoryNFTRegistry from 0xNIFTORY_NFT_REGISTRY_ADDRESS
import MomentableArt from 0xMOMENTABLE_ART_ADDRESS

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
