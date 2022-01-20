import NonFungibleToken from 0x1d7e57aa55817448
import NFTLendingPlace from 0xa0035d8e04880578

// Let the NFT owner unlist NFT from NFTLendingPlace's resource
transaction(Uuid: UInt64) {

    prepare(acct: AuthAccount) {

        let lending = acct.borrow<&NFTLendingPlace.LendingCollection>(from: /storage/NFTLendingPlaceCollection)
            ?? panic("Could not borrow borrower's vault resource")

        // Borrow a reference to the NFTCollection in storage
        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/MusicBlockCollection)
            ?? panic("Could not borrow borrower's NFT collection resource")

        let NFTtoken <- lending.withdraw(uuid: Uuid)

        collectionRef.deposit(token: <- NFTtoken)
    }
}