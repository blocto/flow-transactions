import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import StarlyToken from 0x142fa6570b62fd97
import StarlyTokenStaking from 0x76a9b420a331b9f0

transaction(stakeID: UInt64) {
    let vaultRef: &StarlyToken.Vault
    let stakeCollectionRef: &StarlyTokenStaking.Collection

    prepare(acct: AuthAccount) {
        self.vaultRef = acct.borrow<&StarlyToken.Vault>(from: StarlyToken.TokenStoragePath)
            ?? panic("Could not borrow reference to the owner's StarlyToken vault!")

        self.stakeCollectionRef = acct.borrow<&StarlyTokenStaking.Collection>(from: StarlyTokenStaking.CollectionStoragePath)
            ?? panic("Could not borrow reference to the owner's StarlyTokenStaking collection!")
    }

    execute {
        self.vaultRef.deposit(from: <-self.stakeCollectionRef.unstake(id: stakeID))
    }
}