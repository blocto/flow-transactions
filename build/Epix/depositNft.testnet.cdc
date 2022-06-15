import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import NonFungibleToken from 0x631e88ae7f1d7c20
import Epix from 0x244f523a150d41c1

// This transaction is for depositing a NFT into safe account
transaction(nftIds: [UInt64], userSafeRecipient: Address) {

    let userCollectionRef: &Epix.Collection
    prepare(user: AuthAccount) {
        // borrow a reference to the safe NFT collection
        self.userCollectionRef = user.borrow<&Epix.Collection>(from: Epix.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the user's collection")
    }

    execute {
        // Get the public account object for the user safe recipient
        let recipient = getAccount(userSafeRecipient)

        // borrow a public reference to the receivers collection
        let depositRef = recipient.getCapability(Epix.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        var x = 0;
        // transfer NFT(s) to recipient
        while x < nftIds.length {
            // withdraw the NFT from the owner's collection
            let nft <- self.userCollectionRef.withdraw(withdrawID: nftIds[x])

            // Deposit the NFT in the recipient's collection
            depositRef.deposit(token: <-nft)
            x = x + 1;
        }
    }
}