import NonFungibleToken from 0x1d7e57aa55817448
import EnemyMetal from 0xa38d9dda1d06fdea

// This transaction is for crafting NFT(s)
transaction(nftIds: [UInt64], metadataArray: [String], claimMetadatasArray: [[String]]) {

    // local variable for storing the minter reference
    let crafterStorageCollectionRef: &EnemyMetal.Collection
    let crafterPublicCollectionRef: &{NonFungibleToken.CollectionPublic}
    let minter: &EnemyMetal.NFTMinter
    var nfts: [EnemyMetal.NFTData]

    prepare(crafter: AuthAccount, minter: AuthAccount) {
        pre {
            metadataArray.length == claimMetadatasArray.length : "metadata array must be same size of claim metadatas array"
        }

        // borrow a reference to the crafter's NFT collection
        self.crafterStorageCollectionRef = crafter.borrow<&EnemyMetal.Collection>(from: EnemyMetal.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the crafter's storage collection")

        // Borrow the recipient's public NFT collection reference
        self.crafterPublicCollectionRef = crafter.getCapability(EnemyMetal.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!
        
        // borrow a reference to the NFTMinter resource
        self.minter = minter.borrow<&EnemyMetal.NFTMinter>(from: EnemyMetal.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

        // build nfts data struct
        self.nfts = [];
        var x = 0;
        while x < metadataArray.length {
            var claims: [EnemyMetal.NFTData] = [];
            var currClaims: [String] = claimMetadatasArray[x];
            var y = 0;
            while y < currClaims.length {
                claims.append(EnemyMetal.NFTData(metadata: currClaims[y], claims: []));
                y = y + 1;
            }
            self.nfts.append(EnemyMetal.NFTData(metadata: metadataArray[x], claims: claims));
            x = x + 1;
        }
    }

    execute {
        var x = 0;
        // burn required NFT(s) from crafter
        while x < nftIds.length {
            let nft <- self.crafterStorageCollectionRef.withdraw(withdrawID: nftIds[x]);
            destroy nft;
            x = x + 1;
        }
        // Mint crafted nfts
        x = 0;
        while x < self.nfts.length {
            // Mint the NFT and deposit it to the crafter's collection
            self.minter.mintNFT(recipient: self.crafterPublicCollectionRef, data: self.nfts[x]);
            x = x + 1;
        }
    }
}