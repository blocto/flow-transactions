import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import NFTLendingPlace from 0xMANTLEFI_NFTLENDINGPLACE

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

        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/EternalMomentCollection)
            ?? panic("Could not borrow owner's NFT collection reference")

        collectionRef.deposit(token: <-returnNft)
    }
}
