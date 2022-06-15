import FungibleToken from 0x9a0766d93b6608b7
import MetadataViews from 0x631e88ae7f1d7c20
import NonFungibleToken from 0x631e88ae7f1d7c20
import StarlyToken from 0xf63219072aaddd50
import StarlyTokenStaking from 0x8d1cf508d398c5c2

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