import NonFungibleToken from 0x1d7e57aa55817448
import Inscription from 0xa217c76f53a1a081
import InscriptionMetadata from 0xa217c76f53a1a081

/// Mints a new Inscription into recipient's account

transaction(amount: UInt64) {
    /// local variable for storing the minter reference
    // let minter: &Inscription.InscriptionMinter

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

    /// Previous Inscription ID before the transaction executes
    let mintingIDBefore: UInt64

    prepare(signer: AuthAccount) {
        self.mintingIDBefore = Inscription.totalSupply


        if signer
            .getCapability(Inscription.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>() == nil {
            let collection <- Inscription.createEmptyCollection()
            signer.save(<-collection, to: Inscription.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Inscription.Collection{NonFungibleToken.CollectionPublic, Inscription.InscriptionCollectionPublic, InscriptionMetadata.ResolverCollection}>(
                Inscription.CollectionPublicPath,
                target: Inscription.CollectionStoragePath
            )
        }

        // Borrow the recipient's public Inscription collection reference
        self.recipientCollectionRef = signer
            .getCapability(Inscription.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the recipient's Inscription Collection")

    }

    execute {

        let currentIDString = self.mintingIDBefore.toString()

        // Mint the Inscription and deposit it to the recipient's collection
        Inscription.mintInscription(
            recipient: self.recipientCollectionRef,
            amount: amount
        )

    }

    post {
        self.recipientCollectionRef.getIDs().contains(self.mintingIDBefore): "The next Inscription ID should have been minted and delivered"
        Inscription.totalSupply == self.mintingIDBefore + amount: "The total supply should have been increased by ".concat(amount.toString())
    }
}