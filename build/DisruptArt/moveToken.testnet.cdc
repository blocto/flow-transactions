// DisruptArt.io NFT Token Smart Contract
// Owner     : DisruptionNowMedia www.disruptionnow.com
// Developer : www.BLAZE.ws
// Version: 0.0.1

import DisruptArt from 0x439c2b49c0b2f62b

transaction(tokenIds: [UInt64]) {

    prepare(account: AuthAccount) {
        var count = 0
        let acct = getAccount(0x439c2b49c0b2f62b)
        let recipientRef = acct.getCapability(DisruptArt.disruptArtPublicPath)
        .borrow<&{DisruptArt.DisruptArtCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
        let tokens = tokenIds as [UInt64]
        while count < tokens.length {
            let sellerRef = account.borrow<&DisruptArt.Collection>(from: DisruptArt.disruptArtStoragePath)!
            let tokenId  = tokens[count] 
            let token <- sellerRef.withdraw(withdrawID: tokenId)
            count = count + 1 
            recipientRef.deposit(token: <-token)
        }

    }
}