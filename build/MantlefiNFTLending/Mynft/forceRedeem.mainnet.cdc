import NonFungibleToken from 0x1d7e57aa55817448
import NFTLendingPlace from 0xa0035d8e04880578

// Let the lender get borrower's NFT by force
transaction(Uuid: UInt64, BorrowerAddress: Address) {

    prepare(acct: AuthAccount) {

        let borrower = getAccount(BorrowerAddress)

        let lendingPlace = borrower.getCapability<&AnyResource{NFTLendingPlace.LendingPublic}>(/public/NFTLendingPlaceCollection)
            .borrow()
            ?? panic("Could not borrow borrower's NFT Lending Place resource")

        let ticketRef =  acct.borrow<&NFTLendingPlace.LenderTicket>(from: /storage/NFTLendingPlaceCollectionLenderTicket)
            ?? panic("Could not borrow lender's LenderTicket resource")

        let returnNft <- lendingPlace.forcedRedeem(uuid: Uuid, lendticket: ticketRef)

        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/MynftCollection)
            ?? panic("Could not borrow owner's NFT collection reference")

        collectionRef.deposit(token: <-returnNft)
    }
}