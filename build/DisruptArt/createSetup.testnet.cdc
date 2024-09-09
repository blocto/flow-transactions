// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptArt www.Disrupt.art
// Developer : www.BLAZE.ws
// Version: 0.0.1
// Desc: This transaction initilizes DisruptArt Storage Path & Collection to new Dapper wallet accounts.

import DisruptArt from 0x439c2b49c0b2f62b
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

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