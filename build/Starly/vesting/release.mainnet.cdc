import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import StarlyTokenVesting from 0xee2f049f0ba04f0e

transaction(vestingID: UInt64) {
    let vestingCollectionRef: &StarlyTokenVesting.Collection

    prepare(acct: AuthAccount) {
        self.vestingCollectionRef = acct.borrow<&StarlyTokenVesting.Collection>(from: StarlyTokenVesting.CollectionStoragePath)
            ?? panic("Could not borrow reference to the owner's StarlyTokenVesting collection!")
    }

    execute {
        self.vestingCollectionRef.release(id: vestingID)
    }
}