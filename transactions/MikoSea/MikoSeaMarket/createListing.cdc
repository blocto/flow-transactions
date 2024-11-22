// createListing v3.0
import MetadataViews from 0xMETADATA_VIEWS_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import MIKOSEANFT from 0xMIKOSEA_MIKOSEANFT_ADDRESS
import MIKOSEANFTV2 from 0xMIKOSEA_MIKOSEANFTV2_ADDRESS
import MikoSeaMarket from 0xMIKOSEA_MARKET_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_ADDRESS

access(all) fun getNftV2Metadata(addr: Address, nftID: UInt64): {String:String} {
    let account = getAccount(addr)
    let collectioncap = account.capabilities.get<&{MIKOSEANFTV2.CollectionPublic}>(MIKOSEANFTV2.CollectionPublicPath)
    let collectionRef = collectioncap.borrow() ?? panic("Could not borrow collection capability")

    let nft = collectionRef.borrowMIKOSEANFTV2(id: nftID)
    if nft == nil {
        return {}
    }
    let nftAs = nft!
    return nftAs.getMetadata()
}

access(all) fun validateNftExpeiredDate(nftType: String, address: Address, nftID: UInt64) {
    if nftType == "mikoseav2" {
        let metadata = getNftV2Metadata(addr: address, nftID: nftID)
        let start_at_unix = UInt64.fromString(metadata["start_at"] ?? "")
        let end_at_unix = UInt64.fromString(metadata["end_at"] ?? "")
        let next_expired_at_unix = UInt64.fromString(metadata["next_expired_at"] ?? "")
        let currentTime = getCurrentBlock().timestamp

        if start_at_unix != nil {
            if UFix64(start_at_unix!) > currentTime {
                panic("NFT_START_AT_IS_INVALID")
            }
        }
        if end_at_unix != nil {
            if UFix64(end_at_unix!) < currentTime {
                panic("NFT_END_AT_IS_INVALID")
            }
        }
        if next_expired_at_unix != nil {
            if UFix64(next_expired_at_unix!) < currentTime {
                panic("NFT_NEXT_EXPIRED_AT_IS_INVALID")
            }
        }
    }
}

access(all) fun getRoyaltiesV1(address: Address, nftID: UInt64): MetadataViews.Royalties {
    if !MIKOSEANFT.checkCollection(address) {
        panic("ACCOUNT_NOT_SETUP")
    }

    // check holder holds NFT
    let nftData = MIKOSEANFT.fetch(_from: address, itemId:nftID) ?? panic("NFT_NOT_FOUND")
    let projectId = nftData.data.projectId

    let projectCreatorFee = MIKOSEANFT.getProjectCreatorFee(projectId: projectId) ?? 0.1
    let projectCreatorAddress = MIKOSEANFT.getProjectCreatorAddress(projectId: projectId)!
    let platfromFee = MIKOSEANFT.getProjectPlatformFee(projectId: projectId) ?? 0.05
    return MetadataViews.Royalties([
        MetadataViews.Royalty(
            receiver: getAccount(projectCreatorAddress).capabilities.get<&{FungibleToken.Receiver}>(MIKOSEANFT.CollectionPublicPath),
            cut: projectCreatorFee,
            description: "Creator fee"
        ),
        MetadataViews.Royalty(
            receiver: getAccount(MikoSeaMarket.getAdminAddress()).capabilities.get<&{FungibleToken.Receiver}>(MIKOSEANFT.CollectionPublicPath),
            cut: platfromFee,
            description: "Platform fee"
        )
    ])
}

access(all) fun getRoyaltiesV2(address: Address, nftID: UInt64): MetadataViews.Royalties {
    let collectionRef = getAccount(address).capabilities.get<&{MIKOSEANFTV2.CollectionPublic}>(MIKOSEANFTV2.CollectionPublicPath).borrow() ?? panic("ACCOUNT_NOT_SETUP")
    let nft = collectionRef.borrowMIKOSEANFTV2(id: nftID) ?? panic("NFT_NOT_FOUND")
    return nft.getRoyaltiesMarket()
}

transaction(nftID: UInt64, salePrice: UFix64, nftversion: String) {
    let holderCap: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefrontRef: &MikoSeaMarket.Storefront
    let royalties: MetadataViews.Royalties
    let nftType: Type

    prepare(account: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        pre {
            nftversion == "mikosea" || nftversion == "mikoseav2": "nftversion must be mikosea or mikoseav2".concat(", got ").concat(nftversion)
        }

        // setup account
        // for MIKOSAENFT
        let mikoseaCollectionData = MIKOSEANFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")
        // Return early if the account already has a collection
        if account.storage.borrow<&MIKOSEANFT.Collection>(from: mikoseaCollectionData.storagePath) == nil {
            // Create a new empty collection
            let collection <- MIKOSEANFT.createEmptyCollection(nftType: Type<@MIKOSEANFT.NFT>())

            // save it to the account
            account.storage.save(<-collection, to: mikoseaCollectionData.storagePath)

            // create a public capability for the collection
            account.capabilities.unpublish(mikoseaCollectionData.publicPath)
            let collectionCap = account.capabilities.storage.issue<&MIKOSEANFT.Collection>(mikoseaCollectionData.storagePath)
            account.capabilities.publish(collectionCap, at: mikoseaCollectionData.publicPath)
        }

        // for MIKOSAENFTV2
        let mikoseav2CollectionData = MIKOSEANFTV2.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")
        // Return early if the account already has a collection
        if account.storage.borrow<&MIKOSEANFTV2.Collection>(from: mikoseav2CollectionData.storagePath) == nil {
            // Create a new empty collection
            let collection <- MIKOSEANFTV2.createEmptyCollection(nftType: Type<@MIKOSEANFTV2.NFT>())

            // save it to the account
            account.storage.save(<-collection, to: mikoseav2CollectionData.storagePath)

            // create a public capability for the collection
            account.capabilities.unpublish(mikoseav2CollectionData.publicPath)
            let collectionCap = account.capabilities.storage.issue<&MIKOSEANFTV2.Collection>(mikoseav2CollectionData.storagePath)
            account.capabilities.publish(collectionCap, at: mikoseav2CollectionData.publicPath)
        }

        // for storefont
        if account.storage.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) == nil {
            // Create a new empty collection
            let storefront <- MikoSeaMarket.createStorefront()

            // save it to the account
            account.storage.save(<-storefront, to: MikoSeaMarket.MarketStoragePath)

            // create a public capability for the collection
            account.capabilities.unpublish(MikoSeaMarket.MarketPublicPath)
            account.capabilities.publish(account.capabilities.storage.issue<&MikoSeaMarket.Storefront>(MikoSeaMarket.MarketStoragePath), at: MikoSeaMarket.MarketPublicPath)
        }
        if let storefrontRef = account.storage.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) {
            self.storefrontRef = storefrontRef
        } else {
            panic("Something went wrong!")
        }

        // validate nft
        validateNftExpeiredDate(nftType: nftversion, address: account.address, nftID: nftID)

        if nftversion == "mikosea" {
            // get royalties
            self.royalties = getRoyaltiesV1(address: account.address, nftID: nftID)

            // link private collection
            // let MIKOSEANFTPrivatePath = /private/MIKOSEANFTCollection
            // if !account.capabilities.get<&MIKOSEANFT.Collection>(MIKOSEANFTPrivatePath).check() {
            //     account.link<&MIKOSEANFT.Collection>(MIKOSEANFTPrivatePath, target: MIKOSEANFT.CollectionStoragePath)
            // }
            self.holderCap = account.capabilities.storage.issue<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFT.CollectionStoragePath)

            // get nft type
            self.nftType = Type<@MIKOSEANFT.NFT>()
        } else {
            // get royalties
            self.royalties = getRoyaltiesV2(address: account.address, nftID: nftID)

            // link private collection
            // let MIKOSEANFTV2PrivatePath = /private/MIKOSEANFTV2Collection
            // if !account.capabilities.get<&MIKOSEANFTV2.Collection>(MIKOSEANFTV2PrivatePath).check() {
            //     account.link<&MIKOSEANFTV2.Collection>(MIKOSEANFTV2PrivatePath, target: MIKOSEANFTV2.CollectionStoragePath)
            // }
            // self.holderCap = account.capabilities.get<&MIKOSEANFTV2.Collection>(MIKOSEANFTV2PrivatePath)
            self.holderCap = account.capabilities.storage.issue<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTV2.CollectionStoragePath)

            // get nft type
            self.nftType = Type<@MIKOSEANFTV2.NFT>()

            let holder = account.storage.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath)!
            holder.setInMarket(nftID: nftID, value: true)
        }
    }

    execute {
        self.storefrontRef.createOrder(
            nftType: self.nftType,
            nftID: nftID,
            holderCap: self.holderCap,
            salePrice: salePrice,
            royalties: self.royalties,
            metadata: {}
        )
    }
}
