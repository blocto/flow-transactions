import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
import FUSD from 0x3c5959b568896393
import FlowSwapPair from 0xc6c77b9f5c7a378f
import FusdUsdtSwapPair from 0x87f3f233f34b0733
import StarlyCardMarket from 0x5b82f21c0edf76e3
import StarlyPack from 0x5b82f21c0edf76e3

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
    let beneficiaryFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let creatorFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let buyerAddress: Address
    let beneficiarySaleCutReceiver: StarlyCardMarket.SaleCutReceiver
    let creatorSaleCutReceiver: StarlyCardMarket.SaleCutReceiver
    let additionalSaleCutReceivers: [StarlyCardMarket.SaleCutReceiver]

    prepare(signer: AuthAccount) {
        self.buyerAddress = signer.address;

        let amountUsdt = FusdUsdtSwapPair.quoteSwapToken2ForExactToken1(amount: price)
        let amountFlow = FlowSwapPair.quoteSwapToken1ForExactToken2(amount: amountUsdt) / (1.0 - FlowSwapPair.feePercentage) + 0.00001

        // swap Flow to FUSD
        let flowVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow a reference to Vault")
        let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow a reference to Vault")

        let token1Vault <- flowVault.withdraw(amount: amountFlow) as! @FlowToken.Vault
        let token2Vault <- FlowSwapPair.swapToken1ForToken2(from: <-token1Vault)
        let token3Vault <- FusdUsdtSwapPair.swapToken2ForToken1(from: <-token2Vault)

        let beneficiary = getAccount(beneficiaryAddress);
        self.beneficiaryFUSDVault = beneficiary.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.beneficiaryFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (beneficiary)")
        self.beneficiarySaleCutReceiver = StarlyCardMarket.SaleCutReceiver(receiver: self.beneficiaryFUSDVault, percent: beneficiaryCutPercent)

        let creator = getAccount(creatorAddress)
        self.creatorFUSDVault = creator.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.creatorFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (creator)")
        self.creatorSaleCutReceiver = StarlyCardMarket.SaleCutReceiver(receiver: self.creatorFUSDVault, percent: creatorCutPercent)

        self.additionalSaleCutReceivers = []
        for address in additionalSaleCutsPercents.keys {
            let additionalAccount = getAccount(address);
            let additionalCutPercent = additionalSaleCutsPercents[address]!
            let additionalFUSDVault = additionalAccount.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
            assert(additionalFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver (additional)")
            let additionalSaleCutReceiver = StarlyCardMarket.SaleCutReceiver(receiver: additionalFUSDVault, percent: additionalCutPercent)
            self.additionalSaleCutReceivers.append(additionalSaleCutReceiver)
        }

        fusdVault.deposit(from: <- token3Vault)
        self.paymentVault <- fusdVault.withdraw(amount: price)
    }

    execute {
        StarlyPack.purchase(
            collectionID: collectionID,
            packIDs: packIDs,
            price: price,
            buyerAddress: self.buyerAddress,
            paymentVault: <- self.paymentVault,
            beneficiarySaleCutReceiver: self.beneficiarySaleCutReceiver,
            creatorSaleCutReceiver: self.creatorSaleCutReceiver,
            additionalSaleCutReceivers: self.additionalSaleCutReceivers)
    }
}