import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTLendingPlace from 0xMANTLEFI_NFTLENDINGPLACE
import FlowToken from 0x1654653399040a61

// List an NFT in the account storage for lending
transaction(id: UInt64, baseAmount: UFix64, interest: UFix64, duration: UFix64) {

    prepare(acct: AuthAccount) {

        // Init
        if acct.borrow<&AnyResource{NFTLendingPlace.LendingPublic}>(from: /storage/NFTLendingPlace) == nil {
            let receiver = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            let lendingPlace <- NFTLendingPlace.createLendingCollection(ownerVault: receiver)
            acct.save(<-lendingPlace, to: /storage/NFTLendingPlace)
            acct.link<&NFTLendingPlace.LendingCollection{NFTLendingPlace.LendingPublic}>(/public/NFTLendingPlace, target: /storage/NFTLendingPlace)
        }

        let lendingPlace = acct.borrow<&NFTLendingPlace.LendingCollection>(from: /storage/NFTLendingPlace)
            ?? panic("Could not borrow borrower's NFT Lending Place resource")

        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/EternalShardCollection)
            ?? panic("Could not borrow borrower's NFT collection resource")

        // Withdraw the NFT to use as collateral
        let token <- collectionRef.withdraw(withdrawID: id)

        // List the NFT as collateral
        lendingPlace.listForLending(owner: acct.address, token: <-token, baseAmount: baseAmount, interest: interest, duration: duration)
    }
}