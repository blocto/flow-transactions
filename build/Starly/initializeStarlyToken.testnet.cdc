import FungibleToken from 0x9a0766d93b6608b7
import StarlyToken from 0xf63219072aaddd50

pub fun hasStarlyToken(_ address: Address): Bool {
    let receiver: Bool = getAccount(address)
        .getCapability<&StarlyToken.Vault{FungibleToken.Receiver}>(StarlyToken.TokenPublicReceiverPath)
        .check()

    let balance: Bool = getAccount(address)
        .getCapability<&StarlyToken.Vault{FungibleToken.Balance}>(StarlyToken.TokenPublicBalancePath)
        .check()

    return receiver && balance
}

transaction {
    prepare(acct: AuthAccount) {
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
    }
}