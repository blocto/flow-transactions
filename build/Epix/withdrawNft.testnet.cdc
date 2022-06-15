import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import NonFungibleToken from 0x631e88ae7f1d7c20
import Epix from 0x244f523a150d41c1

pub fun trySetupNft(acct: AuthAccount) {
    // setup account to receive nfts from epix collection
    if acct.borrow<&Epix.Collection>(from: Epix.CollectionStoragePath) == nil {
        // Create a new empty collection
        let collection <- Epix.createEmptyCollection()
        // save it to the account
        acct.save(<-collection, to: Epix.CollectionStoragePath)
        // create a public capability for the collection
        acct.link<&Epix.Collection{NonFungibleToken.CollectionPublic, Epix.EpixCollectionPublic}>(Epix.CollectionPublicPath as! CapabilityPath, target: Epix.CollectionStoragePath)
    }
}

// This transaction is for withdrawing a NFT and charging a flow fee
transaction(nftIds: [UInt64], feeflowAmount: UFix64, payee: Address) {

    let userCollectionRef: &Epix.Collection
    let payer: AuthAccount

    prepare(user: AuthAccount, payer: AuthAccount) {

        // borrow a reference to the safe NFT collection
        self.userCollectionRef = user.borrow<&Epix.Collection>(from: Epix.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the user's collection")

        // try setup nft collection for payer
        trySetupNft(acct: payer)

        self.payer = payer;
    }

    execute {
        // borrow a reference to payers Flow vault
        let payerVault = self.payer.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault)!

        // deposit tokens to payee
        if feeflowAmount > 0.0 {
            let payeeCap = getAccount(payee).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            if let vaultRef = payeeCap.borrow() {
                vaultRef.deposit(from: <-payerVault.withdraw(amount: UFix64(feeflowAmount)))
            } else {
                panic("couldn't get payee vault ref")
            }
        }

        // borrow a public reference to the payer collection
        let depositRef = self.payer.getCapability(Epix.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

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