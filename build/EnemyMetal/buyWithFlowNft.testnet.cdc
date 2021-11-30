import FungibleToken from 0xFUNGIBLETOKEN
import FlowToken from 0xFLOWTOKEN
import NonFungibleToken from 0xNONFUNGIBLETOKEN
import EnemyMetal from 0xENEMYMETAL

// This transaction is for buying a NFT using flow tokens to a recipient account
transaction(flowAmount: UFix64, payees: [Address], payeesShares: [UFix64], recipient: Address, nft_id: UInt64) {

    let sellerCollectionRef: &EnemyMetal.Collection
    let buyerVault: &FlowToken.Vault{FungibleToken.Provider}

    prepare(seller: AuthAccount, buyer: AuthAccount) {
        pre {
            payees.length > 0 : "need to provide atleast one payee"
            payees.length == payeesShares.length : "need to define each payee share"
        }

        var x = 0
        var sum = 0.0
        while x < payeesShares.length {
            sum = sum + payeesShares[x]
            x = x + 1
        }
        if(sum < 1.0 || sum > 1.0) {
            panic("payees shares need to be equal to 100%")
        }

        self.buyerVault = buyer.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault)!

        // borrow a reference to the sellers NFT collection
        self.sellerCollectionRef = seller.borrow<&EnemyMetal.Collection>(from: EnemyMetal.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the seller's collection")
    }

    execute {
        // deposit tokens to payees
        var x = 0
        while x < payees.length {
            let payeeCap = getAccount(payees[x]).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            if let vaultRef = payeeCap.borrow() {
                vaultRef.deposit(from: <-self.buyerVault.withdraw(amount: UFix64(flowAmount * payeesShares[x])))
            } else {
                panic("couldn't get payee vault ref")
            }
            x = x + 1
        }

        // Get the public account object for the recipient
        let recipient = getAccount(recipient)

        // withdraw the NFT from the owner's collection
        let nft <- self.sellerCollectionRef.withdraw(withdrawID: nft_id)

        // borrow a public reference to the receivers collection
        let depositRef = recipient.getCapability(EnemyMetal.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}