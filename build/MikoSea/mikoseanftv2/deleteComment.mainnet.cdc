import MIKOSEANFTV2 from 0x0b80e42aaab305f0

transaction(commentId: UInt64) {
    let holder: &MIKOSEANFTV2.Collection

    prepare(signer: AuthAccount) {
        self.holder = signer.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) ?? panic("NOT_SETUP")
    }

    execute {
        self.holder.deleteComment(commentId: commentId)
    }
}