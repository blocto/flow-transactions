import NonFungibleToken from 0x631e88ae7f1d7c20
import NFTLendingPlace from 0xca4ee530dafff8ad

// Let the lender get borrower's NFT by force
transaction(Uuid: UInt64, BorrowerAddress: Address) {

    prepare(acct: AuthAccount) {

        let borrower = getAccount(BorrowerAddress)

        let lendingPlace = borrower.getCapability<&AnyResource{NFTLendingPlace.LendingPublic}>(/public/NFTLendingPlace)
            .borrow()
            ?? panic("Could not borrow borrower's NFT Lending Place resource")

        let ticketRef =  acct.borrow<&NFTLendingPlace.LenderTicket>(from: /storage/NFTLendingPlaceLenderTicket)
            ?? panic("Could not borrow lender's LenderTicket resource")

        let returnNft <- lendingPlace.forcedRedeem(uuid: Uuid, lendticket: ticketRef)

        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/FantastecNFTCollection)
            ?? panic("Could not borrow owner's NFT collection reference")

        collectionRef.deposit(token: <-returnNft)
    }
}