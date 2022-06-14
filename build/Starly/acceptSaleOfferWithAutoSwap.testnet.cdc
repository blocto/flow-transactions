import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import FlowToken from 0x7e60df042a9c0868
import FUSD from 0xe223d8a629e49c68
import FlowSwapPair from 0xd9854329b7edf136
import FusdUsdtSwapPair from 0x3502a5dacaf350bb
import StarlyCard from 0x697d72a988a77070
import StarlyCardMarket from 0x697d72a988a77070

transaction(itemID: UInt64, marketCollectionAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let starlyCardCollection: &StarlyCard.Collection{NonFungibleToken.Receiver}
    let marketCollection: &StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}
    let buyerAddress: Address

    prepare(signer: AuthAccount) {
        self.buyerAddress = signer.address;

        self.starlyCardCollection = signer.borrow<&StarlyCard.Collection{NonFungibleToken.Receiver}>(
            from: StarlyCard.CollectionStoragePath
        ) ?? panic("Cannot borrow StarlyCard collection receiver from acct")

        self.marketCollection = getAccount(marketCollectionAddress)
            .getCapability<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(
                StarlyCardMarket.CollectionPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow market collection from market address")

        let saleItem = self.marketCollection.borrowSaleItem(itemID: itemID)
                    ?? panic("No item with that ID")

        let fusdPrice = saleItem.price

        let amountUsdt = FusdUsdtSwapPair.quoteSwapToken2ForExactToken1(amount: fusdPrice)
        let amountFlow = FlowSwapPair.quoteSwapToken1ForExactToken2(amount: amountUsdt) / (1.0 - FlowSwapPair.feePercentage) + 0.00001

        // swap Flow to FUSD
        let flowVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow a reference to Vault")

        let token1Vault <- flowVault.withdraw(amount: amountFlow) as! @FlowToken.Vault
        let token2Vault <- FlowSwapPair.swapToken1ForToken2(from: <-token1Vault)
        let token3Vault <- FusdUsdtSwapPair.swapToken2ForToken1(from: <-token2Vault)

        if signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil {
            // Create a new FUSD Vault and put it in storage
            signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(
                /public/fusdReceiver,
                target: /storage/fusdVault
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(
                /public/fusdBalance,
                target: /storage/fusdVault
            )
        }

        let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow a reference to Vault")

        fusdVault.deposit(from: <- token3Vault)
        self.paymentVault <- fusdVault.withdraw(amount: fusdPrice)
    }

    execute {
        self.marketCollection.purchase(
            itemID: itemID,
            buyerCollection: self.starlyCardCollection,
            buyerPayment: <- self.paymentVault,
            buyerAddress: self.buyerAddress
        )
    }
}