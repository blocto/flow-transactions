// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptArt www.Disrupt.art
// Developer : www.BLAZE.ws
// Version: 0.0.1
// Desc: This transaction initilizes DisruptArt Storage Path & Collection to new Dapper wallet accounts.

import DisruptArt from 0xDISRUPTART_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import MetadataViews from 0xNON_FUNGIBLE_TOKEN_ADDRESS

transaction() {
    
    prepare(acct: AuthAccount) {

        // Return early if the account already has a collection
        if acct.borrow<&DisruptArt.Collection>(from: DisruptArt.disruptArtStoragePath) == nil {

            // Create a new empty collection
            let collection <- DisruptArt.createEmptyCollection()

            // save it to the account
            acct.save(<-collection, to: DisruptArt.disruptArtStoragePath)

            // create a public capability for the collection
            acct.link<&DisruptArt.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, DisruptArt.DisruptArtCollectionPublic}>(
                    DisruptArt.disruptArtPublicPath,
                    target: DisruptArt.disruptArtStoragePath
                    )
        }

   }


}