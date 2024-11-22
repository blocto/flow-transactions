import MIKOSEANFTV2 from 0xMIKOSEA_MIKOSEANFTV2_ADDRESS

transaction(nftIDs: [UInt64], comment: String) {
    let holder: &MIKOSEANFTV2.Collection

    prepare(signer: auth(BorrowValue) &Account) {
        self.holder = signer.storage.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) ?? panic("NOT_SETUP")
    }

    execute {
        for nftID in nftIDs {
            self.holder.createComment(nftID: nftID, comment: comment)
        }
    }
}
