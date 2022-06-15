import FungibleToken from 0xf233dcee88fe0abe
import MetadataViews from 0x1d7e57aa55817448
import NonFungibleToken from 0x1d7e57aa55817448
import StarlyToken from 0x142fa6570b62fd97
import StarlyTokenStaking from 0x76a9b420a331b9f0

transaction(amount: UFix64) {
    let vaultRef: &StarlyToken.Vault
    let stakeCollectionRef: &StarlyTokenStaking.Collection

    prepare(acct: AuthAccount) {
        self.vaultRef = acct.borrow<&StarlyToken.Vault>(from: StarlyToken.TokenStoragePath)
            ?? panic("Could not borrow reference to the owner's StarlyToken vault!")

        if acct.borrow<&StarlyTokenStaking.Collection>(from: StarlyTokenStaking.CollectionStoragePath) == nil {
            acct.save(<-StarlyTokenStaking.createEmptyCollection(), to: StarlyTokenStaking.CollectionStoragePath)
            acct.link<&StarlyTokenStaking.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, StarlyTokenStaking.CollectionPublic}>(
                StarlyTokenStaking.CollectionPublicPath,
                target: StarlyTokenStaking.CollectionStoragePath)
        }
        self.stakeCollectionRef = acct.borrow<&StarlyTokenStaking.Collection>(from: StarlyTokenStaking.CollectionStoragePath)
            ?? panic("Could not borrow reference to the owner's StarlyTokenStaking collection!")
    }

    execute {
        let vault <- self.vaultRef.withdraw(amount: amount) as! @StarlyToken.Vault
        self.stakeCollectionRef.stake(principalVault: <-vault)
    }
}