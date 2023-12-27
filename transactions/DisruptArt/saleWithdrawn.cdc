import DisruptArtMarketplaceFlow from 0xDISRUPTART_ADDRESS

transaction(tokens:[UInt64]) {

    prepare(acct: AuthAccount) {

        let salewithdrawn = acct.borrow<&DisruptArtMarketplaceFlow.SaleCollection>(from: DisruptArtMarketplaceFlow.marketStoragePath)
                    ?? panic("Could not borrow acct nft sale reference")

        let tokenids:[UInt64] = tokens

        // List the token for sale by moving it into the sale object
        salewithdrawn.saleWithdrawn(tokens:tokenids)

    }
} 