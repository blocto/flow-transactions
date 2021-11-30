import FungibleToken from 0xFUNGIBLETOKEN
import FlowToken from 0xFLOWTOKEN
import NonFungibleToken from 0xNONFUNGIBLETOKEN
import EnemyMetal from 0xENEMYMETAL

pub fun trySetupFlow(acct: AuthAccount) {
    // setup account to use flow tokens
    if acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) == nil {
        // Create a new flow Vault and put it in storage
        acct.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        acct.link<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver,
            target: /storage/flowTokenVault
        )
        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        acct.link<&FlowToken.Vault{FungibleToken.Balance}>(
            /public/flowTokenBalance,
            target: /storage/flowTokenVault
        )
    }
}

pub fun trySetupNft(acct: AuthAccount) {
    // setup account to receive nfts from enemymetal collection
    if acct.borrow<&EnemyMetal.Collection>(from: EnemyMetal.CollectionStoragePath) == nil {
        // Create a new empty collection
        let collection <- EnemyMetal.createEmptyCollection()
        // save it to the account
        acct.save(<-collection, to: EnemyMetal.CollectionStoragePath)
        // create a public capability for the collection
        acct.link<&EnemyMetal.Collection{NonFungibleToken.CollectionPublic, EnemyMetal.EnemyMetalCollectionPublic}>(EnemyMetal.CollectionPublicPath as! CapabilityPath, target: EnemyMetal.CollectionStoragePath)
    }
}

pub fun createAccount(pubKeys: [String], payer: AuthAccount): AuthAccount {
    let acct = AuthAccount(payer: payer)
    for key in pubKeys {
        acct.addPublicKey(key.decodeHex())
    }
    trySetupNft(acct: acct)
    trySetupFlow(acct: acct)
    return acct
}

// This transaction is for buying a NFT using flow tokens to a recipient account
transaction(flowAmount: UFix64, payees: [Address], payeesShares: [UFix64], recipientKeys: [String], nft_id: UInt64) {

    let sellerCollectionRef: &EnemyMetal.Collection
    let buyerVault: &FlowToken.Vault{FungibleToken.Provider}
    let recipient: AuthAccount

    prepare(seller: AuthAccount, custodian: AuthAccount, buyer: AuthAccount) {
        pre {
            payees.length > 0 : "need to provide atleast one payee"
            payees.length == payeesShares.length : "need to define each payee share"
            recipientKeys.length > 0 : "need to define atleast one public key"
        }

        self.recipient = createAccount(pubKeys: recipientKeys, payer: custodian)

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

        // withdraw the NFT from the owner's collection
        let nft <- self.sellerCollectionRef.withdraw(withdrawID: nft_id)

        // borrow a public reference to the receivers collection
        let depositRef = self.recipient.getCapability(EnemyMetal.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}