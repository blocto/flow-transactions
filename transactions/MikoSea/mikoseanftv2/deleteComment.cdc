import MIKOSEANFTV2 from 0xMIKOSEA_MIKOSEANFTV2_ADDRESS

transaction(commentId: UInt64) {
    let holder: &MIKOSEANFTV2.Collection

    prepare(signer: auth(BorrowValue) &Account) {
        self.holder = signer.storage.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) ?? panic("NOT_SETUP")
    }

    execute {
        self.holder.deleteComment(commentId: commentId)
    }
}
