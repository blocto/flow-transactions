import MetadataViews from 0x631e88ae7f1d7c20
import NonFungibleToken from 0x631e88ae7f1d7c20
import StarlyTokenVesting from 0xd2af9f588d53759d

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