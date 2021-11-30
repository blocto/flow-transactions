import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import StarlyCardMarket from 0x697d72a988a77070
import StarlyPack from 0x697d72a988a77070

transaction(
    collectionID: String,
    packIDs: [String],
    price: UFix64,
    beneficiaryAddress: Address,
    beneficiaryCutPercent: UFix64,
    creatorAddress: Address,
    creatorCutPercent: UFix64,
    additionalSaleCutsPercents: {Address: UFix64}) {

    let paymentVault: @FungibleToken.Vault
    let beneficiaryVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let creatorVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let buyerAddress: Address
    let beneficiarySaleCutReceiver: StarlyCardMarket.SaleCutReceiverV2
    let creatorSaleCutReceiver: StarlyCardMarket.SaleCutReceiverV2
    let additionalSaleCutReceivers: [StarlyCardMarket.SaleCutReceiverV2]

    prepare(signer: AuthAccount) {
        self.buyerAddress = signer.address;
        let buyerVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FLOW vault from acct storage")
        self.paymentVault <- buyerVault.withdraw(amount: price)

        let beneficiary = getAccount(beneficiaryAddress);
        self.beneficiaryVault = beneficiary.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(self.beneficiaryVault.borrow() != nil, message: "Missing or mis-typed FLOW receiver (beneficiary)")
        self.beneficiarySaleCutReceiver = StarlyCardMarket.SaleCutReceiverV2(receiver: self.beneficiaryVault, percent: beneficiaryCutPercent)

        let creator = getAccount(creatorAddress)
        self.creatorVault = creator.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(self.creatorVault.borrow() != nil, message: "Missing or mis-typed FLOW receiver (creator)")
        self.creatorSaleCutReceiver = StarlyCardMarket.SaleCutReceiverV2(receiver: self.creatorVault, percent: creatorCutPercent)

        self.additionalSaleCutReceivers = []
        for address in additionalSaleCutsPercents.keys {
            let additionalAccount = getAccount(address);
            let additionalCutPercent = additionalSaleCutsPercents[address]!
            let additionalVault = additionalAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
            assert(additionalVault.borrow() != nil, message: "Missing or mis-typed FLOW receiver (additional)")
            let additionalSaleCutReceiver = StarlyCardMarket.SaleCutReceiverV2(receiver: additionalVault, percent: additionalCutPercent)
            self.additionalSaleCutReceivers.append(additionalSaleCutReceiver)
        }
    }

    execute {
        StarlyPack.purchaseV2(
            collectionID: collectionID,
            packIDs: packIDs,
            price: price,
            currency: Type<@FlowToken.Vault>(),
            buyerAddress: self.buyerAddress,
            paymentVault: <- self.paymentVault,
            beneficiarySaleCutReceiver: self.beneficiarySaleCutReceiver,
            creatorSaleCutReceiver: self.creatorSaleCutReceiver,
            additionalSaleCutReceivers: self.additionalSaleCutReceivers)
    }
}