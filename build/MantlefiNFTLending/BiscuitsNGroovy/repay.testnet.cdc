import NonFungibleToken from 0x631e88ae7f1d7c20
import NFTLendingPlace from 0x615a6bf3445b9c61
import FlowToken from 0x7e60df042a9c0868

// Let the borrower to repay FLOW
transaction(Uuid: UInt64, RepayAmount: UFix64) {

    let temporaryVault: @FlowToken.Vault
    let collectionRef: &NonFungibleToken.Collection
    let landingPlaceRef: &NFTLendingPlace.LendingCollection

    prepare(acct: AuthAccount) {

        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow borrower's vault reference")

        self.temporaryVault <- vaultRef.withdraw(amount: RepayAmount) as! @FlowToken.Vault

        self.collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/BnGNFTCollection)
            ?? panic("Could not borrow borrower's NFT collection reference")

         self.landingPlaceRef =  acct.borrow<&NFTLendingPlace.LendingCollection>(from: /storage/NFTLendingPlace)
            ?? panic("Could not borrow borrower's LenderTicket reference")
    }

    execute {
        let returnNft <- self.landingPlaceRef.repay(uuid: Uuid, repayAmount: <-self.temporaryVault)

        self.collectionRef.deposit(token: <-returnNft)
    }
}