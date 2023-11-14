import NonFungibleToken from 0xNonFungibleToken
import MUMGJ from 0xMUMGJ
      transaction {
        prepare(acct: AuthAccount) {
          if acct.borrow<&MUMGJ.Collection>(from: MUMGJ.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- MUMGJ.createEmptyCollection()
            // save it to the account
            acct.save(<-collection, to: MUMGJ.CollectionStoragePath)
            // create a public capability for the collection
            acct.link<&MUMGJ.Collection{NonFungibleToken.CollectionPublic, MUMGJ.MUMGJCollectionPublic}>(MUMGJ.CollectionPublicPath, target: MUMGJ.CollectionStoragePath)
          }
        }
        execute {
        }
      }