import MIKOSEANFT from 0x713306ac51ac7ddb

transaction(commentIds:[UInt64]){
  execute{
    for commentId in commentIds {
      MIKOSEANFT.deleteComment(commentId: commentId)
    }
  }
}