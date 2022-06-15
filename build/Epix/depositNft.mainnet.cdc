import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
import NonFungibleToken from 0x1d7e57aa55817448
import Epix from 0xcc838e3f0213008f

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