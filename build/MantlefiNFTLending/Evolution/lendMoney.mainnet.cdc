import NFTLendingPlace from 0xa0035d8e04880578
import FlowToken from 0x1654653399040a61

// Let the lender lend FLOW to borrower
transaction(BorrowerAddress: Address, LenderAddress: Address, Uuid: UInt64, LendAmount: UFix64) {

    let temporaryVault: @FlowToken.Vault

    let ticketRef:  &NFTLendingPlace.LenderTicket

    prepare(acct: AuthAccount) {

        // Init
        if acct.borrow<&NFTLendingPlace.LenderTicket>(from: /storage/NFTLendingPlaceCollectionLenderTicket) == nil {
            let lendingTicket <- NFTLendingPlace.createLenderTicket()
            acct.save(<-lendingTicket, to: /storage/NFTLendingPlaceCollectionLenderTicket)
        }

        self.ticketRef = acct.borrow<&NFTLendingPlace.LenderTicket>(from: /storage/NFTLendingPlaceCollectionLenderTicket)
            ?? panic("Could not borrow lender's LenderTicket reference")

        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow lender's vault reference")

        self.temporaryVault <- vaultRef.withdraw(amount: LendAmount) as! @FlowToken.Vault
    }

    execute {

        let borrower = getAccount(BorrowerAddress)

        let lendingPlaceRef = borrower.getCapability<&AnyResource{NFTLendingPlace.LendingPublic}>(/public/NFTLendingPlaceCollection)
            .borrow()
            ?? panic("Could not borrow borrower's NFT Lending Place recource")

        lendingPlaceRef.lendOut(uuid: Uuid, recipient: LenderAddress, lendAmount: <-self.temporaryVault, ticket:  self.ticketRef)
    }
}