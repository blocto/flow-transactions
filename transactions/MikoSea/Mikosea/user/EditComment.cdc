// EditComment-v2
import MIKOSEANFT from 0xMIKOSEA_MIKOSEANFT_ADDRESS

transaction(commentId:UInt64, comment: String){
    let address: Address
    var commentDetail: MIKOSEANFT.Comment?

    prepare(signer: &Account) {
        self.address = signer.address
        self.commentDetail = nil
        let comments = MIKOSEANFT.getAllComments()
        for e in comments {
            if e.commentId == commentId {
                self.commentDetail = e
                break
            }
        }
        if self.commentDetail == nil {
            panic("not found comment")
        }
    }

    execute{
        MIKOSEANFT.editComment(commentId: commentId, projectId: self.commentDetail!.projectId, itemId: self.commentDetail!.itemId, userAddress: self.address, nftId: self.commentDetail!.nftId, newComment: comment)
    }
}
