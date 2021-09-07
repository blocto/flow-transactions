import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import FUSD from 0xFUSD_ADDRESS
import StarlyCardMarket from 0xSTARLY_CARD_MARKET_ADDRESS
import StarlyPack from 0xSTARLY_PACK_ADDRESS

transaction(
    collectionID: String,
    packIDs: [String],
    price: UFix64,
    beneficiaryAddress: Address,
    beneficiaryCutPercent: UFix64,
    creatorAddress: Address,
    creatorCutPercent: UFix64) {

    let paymentVault: @FungibleToken.Vault
    let beneficiaryFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let creatorFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let buyerAddress: Address

    prepare(signer: AuthAccount) {
        self.buyerAddress = signer.address;
        let buyerFUSDVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.paymentVault <- buyerFUSDVault.withdraw(amount: price)

        let beneficiary = getAccount(beneficiaryAddress);
        self.beneficiaryFUSDVault = beneficiary.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.beneficiaryFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (beneficiary)")

        let creator = getAccount(creatorAddress)
        self.creatorFUSDVault = creator.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.creatorFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (creator)")
    }

    execute {
        StarlyPack.purchase(
            collectionID: collectionID,
            packIDs: packIDs,
            price: price,
            buyerAddress: self.buyerAddress,
            paymentVault: <- self.paymentVault,
            beneficiarySaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: self.beneficiaryFUSDVault,
                percent: beneficiaryCutPercent),
            creatorSaleCutReceiver: StarlyCardMarket.SaleCutReceiver(
                receiver: self.creatorFUSDVault,
                percent: creatorCutPercent),
            additionalSaleCutReceivers: [])
    }
}