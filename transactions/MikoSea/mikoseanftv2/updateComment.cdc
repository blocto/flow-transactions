 import MIKOSEANFTV2 from "../../contracts/MIKOSEANFTV2.cdc"

transaction(commentId: UInt64, comment: String) {
    let holder: &MIKOSEANFTV2.Collection

    prepare(signer: AuthAccount) {
        self.holder = signer.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) ?? panic("NOT_SETUP")
    }

    execute {
        self.holder.updateComment(commentId: commentId, comment: comment)
    }
}