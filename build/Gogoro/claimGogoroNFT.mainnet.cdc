import NonFungibleToken from 0x1d7e57aa55817448
import GogoroCollectible from 0x8c9bbcdcd7514081
import BloctoStorageRent from 0x1dfd1e5b87b847dc

transaction(itemID: UInt64, codeHash: String) {
    let minter: &GogoroCollectible.Admin
    let userAddress: Address
    prepare(user: AuthAccount, admin: AuthAccount) {
        self.minter = admin
            .borrow<&GogoroCollectible.Admin>(from: GogoroCollectible.AdminStoragePath)
            ?? panic("admin account is not the minter")
        self.userAddress = user.address
        // If user does not have Gogoro enabled yet, enable now
        if user.borrow<&GogoroCollectible.Collection>(from: GogoroCollectible.CollectionStoragePath) == nil {
            let collection <- GogoroCollectible.createEmptyCollection() as! @GogoroCollectible.Collection
            user.save(<-collection, to: GogoroCollectible.CollectionStoragePath)
            user.link<&GogoroCollectible.Collection{NonFungibleToken.CollectionPublic, GogoroCollectible.CollectionPublic}>(
                GogoroCollectible.CollectionPublicPath,
                target: GogoroCollectible.CollectionStoragePath)
        }
    }
    execute {
        let userAccount = getAccount(self.userAddress)
        let receiverRef = userAccount.getCapability(GogoroCollectible.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow receiver reference to the user's collection")
        self.minter.mintNFT(recipient: receiverRef, itemID: itemID, codeHash: codeHash)
        // Replenish storage fee
        BloctoStorageRent.tryRefill(self.userAddress)
    }
}