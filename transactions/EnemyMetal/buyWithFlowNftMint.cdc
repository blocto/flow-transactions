import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import EnemyMetal from 0xENEMY_METAL_ADDRESS

// This transaction is for buying a NFT mint using flow tokens
transaction(flowAmount: UFix64, payees: [Address], payeesShares: [UFix64], recipient: Address, editionID: UInt64, metadata: String, components: [UInt64], claimEditions: [UInt64], claimMetadatas: [String]) {

    let minter: &EnemyMetal.NFTMinter
    let buyerVault: &FlowToken.Vault{FungibleToken.Provider}
    var data: EnemyMetal.NFTData

    prepare(minter: AuthAccount, buyer: AuthAccount) {
        pre {
            claimEditions.length == claimMetadatas.length : "claim editions must be same size of claim metadatas"
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

        // borrow a reference to the NFTMinter resource in storage
        self.minter = minter.borrow<&EnemyMetal.NFTMinter>(from: EnemyMetal.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

        var claims: [EnemyMetal.NFTData] = [];
        x = 0
        while x < claimEditions.length {
            claims.append(EnemyMetal.NFTData(editionID: claimEditions[x], metadata: claimMetadatas[x], components: [], claims: []))
            x = x + 1
        }
        self.data = EnemyMetal.NFTData(editionID: editionID, metadata: metadata, components: components, claims: claims)
        self.buyerVault = buyer.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault)!
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

        // Borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(EnemyMetal.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, data: self.data)
    }
}