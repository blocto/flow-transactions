import FiatToken from 0xa983fecbed621163
import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import MetadataViews from 0x631e88ae7f1d7c20
import NonFungibleToken from 0x631e88ae7f1d7c20
import StarlyCard from 0x697d72a988a77070
import StarlyCardMarket from 0x697d72a988a77070
import StarlyToken from 0xf63219072aaddd50
import StarlyTokenStaking from 0x8d1cf508d398c5c2

pub fun hasFiatToken(_ address: Address): Bool {
    let receiver: Bool = getAccount(address)
        .getCapability<&FiatToken.Vault{FungibleToken.Receiver}>(FiatToken.VaultReceiverPubPath)
        .check()
    let balance: Bool = getAccount(address)
        .getCapability<&FiatToken.Vault{FungibleToken.Balance}>(FiatToken.VaultBalancePubPath)
        .check()
    return receiver && balance
}

pub fun hasFUSD(_ address: Address): Bool {
    let receiver: Bool = getAccount(address)
        .getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)
        .check()
    let balance: Bool = getAccount(address)
        .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
        .check()
    return receiver && balance
}

pub fun hasStarlyCard(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&StarlyCard.Collection{NonFungibleToken.CollectionPublic, StarlyCard.StarlyCardCollectionPublic}>(StarlyCard.CollectionPublicPath)
        .check()
}

pub fun hasStarlyCardMarket(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(StarlyCardMarket.CollectionPublicPath)
        .check()
}

pub fun hasStarlyToken(_ address: Address): Bool {
    let receiver: Bool = getAccount(address)
        .getCapability<&StarlyToken.Vault{FungibleToken.Receiver}>(StarlyToken.TokenPublicReceiverPath)
        .check()

    let balance: Bool = getAccount(address)
        .getCapability<&StarlyToken.Vault{FungibleToken.Balance}>(StarlyToken.TokenPublicBalancePath)
        .check()

    return receiver && balance
}

pub fun hasStarlyTokenStaking(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&StarlyTokenStaking.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, StarlyTokenStaking.CollectionPublic}>(StarlyTokenStaking.CollectionPublicPath)
        .check()
}

transaction {
    prepare(acct: AuthAccount) {
        if !hasFiatToken(acct.address) {
            if acct.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath) == nil {
                acct.save(<-FiatToken.createEmptyVault(), to: FiatToken.VaultStoragePath)
            }
            acct.unlink(FiatToken.VaultReceiverPubPath)
            acct.unlink(FiatToken.VaultBalancePubPath)
            acct.link<&FiatToken.Vault{FungibleToken.Receiver}>(FiatToken.VaultReceiverPubPath, target: FiatToken.VaultStoragePath)
            acct.link<&FiatToken.Vault{FungibleToken.Balance}>(FiatToken.VaultBalancePubPath, target: FiatToken.VaultStoragePath)
        }

        if !hasFUSD(acct.address) {
            if acct.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil {
                acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            }
            acct.unlink(/public/fusdReceiver)
            acct.unlink(/public/fusdBalance)
            acct.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            acct.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }

        if !hasStarlyCard(acct.address) {
            if acct.borrow<&StarlyCard.Collection>(from: StarlyCard.CollectionStoragePath) == nil {
                acct.save(<-StarlyCard.createEmptyCollection(), to: StarlyCard.CollectionStoragePath)
            }
            acct.unlink(StarlyCard.CollectionPublicPath)
            acct.link<&StarlyCard.Collection{NonFungibleToken.CollectionPublic, StarlyCard.StarlyCardCollectionPublic}>(StarlyCard.CollectionPublicPath, target: StarlyCard.CollectionStoragePath)
        }

        if !hasStarlyCardMarket(acct.address) {
             if acct.borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath) == nil {
                 acct.save(<-StarlyCardMarket.createEmptyCollection(), to: StarlyCardMarket.CollectionStoragePath)
             }
             acct.unlink(StarlyCardMarket.CollectionPublicPath)
             acct.link<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(StarlyCardMarket.CollectionPublicPath, target: StarlyCardMarket.CollectionStoragePath)
        }

        if !hasStarlyToken(acct.address) {
            if acct.borrow<&StarlyToken.Vault>(from: StarlyToken.TokenStoragePath) == nil {
                acct.save(<-StarlyToken.createEmptyVault(), to: StarlyToken.TokenStoragePath)
            }
            acct.unlink(StarlyToken.TokenPublicReceiverPath)
            acct.unlink(StarlyToken.TokenPublicBalancePath)
            acct.link<&StarlyToken.Vault{FungibleToken.Receiver}>(
                StarlyToken.TokenPublicReceiverPath,
                target: StarlyToken.TokenStoragePath)
            acct.link<&StarlyToken.Vault{FungibleToken.Balance}>(
                StarlyToken.TokenPublicBalancePath,
                target: StarlyToken.TokenStoragePath)
        }

        if !hasStarlyTokenStaking(acct.address) {
            if acct.borrow<&StarlyTokenStaking.Collection>(from: StarlyTokenStaking.CollectionStoragePath) == nil {
                acct.save(<-StarlyTokenStaking.createEmptyCollection(), to: StarlyTokenStaking.CollectionStoragePath)
            }
            acct.unlink(StarlyTokenStaking.CollectionPublicPath)
            acct.link<&StarlyTokenStaking.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, StarlyTokenStaking.CollectionPublic}>(
                StarlyTokenStaking.CollectionPublicPath,
                target: StarlyTokenStaking.CollectionStoragePath)
       }
    }
}