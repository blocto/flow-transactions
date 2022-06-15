import MetadataViews from 0x1d7e57aa55817448
import NonFungibleToken from 0x1d7e57aa55817448
import StarlyTokenVesting from 0xee2f049f0ba04f0e

transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&StarlyTokenVesting.Collection>(from: StarlyTokenVesting.CollectionStoragePath) == nil {
            acct.save(<-StarlyTokenVesting.createEmptyCollectionAndNotify(beneficiary: acct.address), to: StarlyTokenVesting.CollectionStoragePath)
            acct.link<&StarlyTokenVesting.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, StarlyTokenVesting.CollectionPublic}>(
                StarlyTokenVesting.CollectionPublicPath,
                target: StarlyTokenVesting.CollectionStoragePath)
        }
    }
}