import DisruptArt from 0xcd946ef9b13804c6

transaction(recpAccount: Address, tokenIds: [UInt64]) {

prepare(account: AuthAccount) {
        var count = 0
        let acct = getAccount(recpAccount)
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