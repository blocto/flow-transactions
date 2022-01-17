import NonFungibleToken from 0x631e88ae7f1d7c20
import NFTLendingPlace from 0xca4ee530dafff8ad

// Let the NFT owner unlist NFT from NFTLendingPlace's resource
transaction(Uuid: UInt64) {

    prepare(acct: AuthAccount) {

        let lending = acct.borrow<&NFTLendingPlace.LendingCollection>(from: /storage/NFTLendingPlace)
            ?? panic("Could not borrow borrower's vault resource")

        // Borrow a reference to the NFTCollection in storage
        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/NyatheesOVOCollection)
            ?? panic("Could not borrow borrower's NFT collection resource")

        let NFTtoken <- lending.withdraw(uuid: Uuid)

        collectionRef.deposit(token: <- NFTtoken)
    }
}