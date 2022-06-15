import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import StarlyTokenVesting from 0xSTARLY_TOKEN_VESTING_ADDRESS

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
