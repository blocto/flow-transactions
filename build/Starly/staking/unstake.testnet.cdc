import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import StarlyToken from 0xf63219072aaddd50
import StarlyTokenStaking from 0x8d1cf508d398c5c2

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