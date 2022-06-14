import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import NonFungibleToken from 0x631e88ae7f1d7c20
import EnemyMetal from 0x244f523a150d41c1

// This transaction is for buying a NFT mint using flow tokens
transaction(flowAmount: UFix64, payees: [Address], payeesShares: [UFix64], recipient: Address, metadataArray: [String], claimMetadatasArray: [[String]]) {

    let minter: &EnemyMetal.NFTMinter
    let buyerVault: &FlowToken.Vault{FungibleToken.Provider}
    var nfts: [EnemyMetal.NFTData]

    prepare(minter: AuthAccount, buyer: AuthAccount) {
        pre {
            metadataArray.length == claimMetadatasArray.length : "metadata array must be same size of claim metadatas array"
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

        // build nfts data struct
        self.nfts = [];
        x = 0;
        while x < metadataArray.length {
            var claims: [EnemyMetal.NFTData] = [];
            var currClaims: [String] = claimMetadatasArray[x];
            var y = 0;
            while y < currClaims.length {
                claims.append(EnemyMetal.NFTData(editionID: 0, metadata: currClaims[y], components: [], claims: []));
                y = y + 1;
            }
            self.nfts.append(EnemyMetal.NFTData(editionID: 0, metadata: metadataArray[x], components: [], claims: claims));
            x = x + 1;
        }

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

        x = 0;
        while x < self.nfts.length {
            // Mint the NFT and deposit it to the recipient's collection
            self.minter.mintNFT(recipient: receiver, data: self.nfts[x]);
            x = x + 1;
        }
    }
}