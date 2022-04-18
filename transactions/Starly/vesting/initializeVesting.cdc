import MetadataViews from 0xMETADATA_VIEWS_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS
import StarlyTokenVesting from 0xSTARLY_TOKEN_VESTING_ADDRESS

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
