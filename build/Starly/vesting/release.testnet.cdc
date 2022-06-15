import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import StarlyTokenVesting from 0xd2af9f588d53759d

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