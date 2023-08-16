// batchCreateComment v2
import MIKOSEANFT from 0xMIKOSEA_MIKOSEANFT_ADDRESS

transaction(nftIDs:[UInt64], comment: String){
    let address: Address
    let projectId:UInt64
    let itemId:UInt64

    prepare(signer:AuthAccount){
        self.address = signer.address
        if let nftData = MIKOSEANFT.fetch(_from: self.address, itemId: nftIDs[0]) {
            self.projectId = nftData.data.projectId
            self.itemId = nftData.data.itemId
        } else {
            panic("Not found nft")
        }
    }
    execute{
        for nftId in nftIDs {
            MIKOSEANFT.createComment(projectId:self.projectId, itemId:self.itemId, userAddress:self.address, nftId:nftId, comment: comment)
        }
    }
}
