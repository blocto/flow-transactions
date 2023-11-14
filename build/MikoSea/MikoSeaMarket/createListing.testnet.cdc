// createListingV1.1
import MikoSeaMarket from 0x713306ac51ac7ddb
import MIKOSEANFT from 0x713306ac51ac7ddb
import MIKOSEANFTV2 from 0x713306ac51ac7ddb
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

pub fun getNftV2Metadata(addr: Address, nftID: UInt64): {String:String} {
    let account = getAccount(addr)
    let collectioncap = account.getCapability<&{MIKOSEANFTV2.CollectionPublic}>(MIKOSEANFTV2.CollectionPublicPath)
    let collectionRef = collectioncap.borrow() ?? panic("Could not borrow collection capability")

    let nft = collectionRef.borrowMIKOSEANFTV2(id: nftID)
    if nft == nil {
        return {}
    }
    let nftAs = nft!
    return nftAs.getMetadata()
}

pub fun validateNftExpeiredDate(nftType: String, address: Address, nftID: UInt64) {
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

pub fun getRoyaltiesV1(address: Address, nftID: UInt64): MetadataViews.Royalties {
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
            receiver: getAccount(projectCreatorAddress).getCapability<&AnyResource{FungibleToken.Receiver}>(MIKOSEANFT.CollectionPublicPath),
            cut: projectCreatorFee,
            description: "Creator fee"
        ),
        MetadataViews.Royalty(
            receiver: getAccount(MikoSeaMarket.getAdminAddress()).getCapability<&AnyResource{FungibleToken.Receiver}>(MIKOSEANFT.CollectionPublicPath),
            cut: platfromFee,
            description: "Platform fee"
        )
    ])
}

pub fun getRoyaltiesV2(address: Address, nftID: UInt64): MetadataViews.Royalties {
    let collectionRef = getAccount(address).getCapability<&{MIKOSEANFTV2.CollectionPublic}>(MIKOSEANFTV2.CollectionPublicPath).borrow() ?? panic("ACCOUNT_NOT_SETUP")
    let nft = collectionRef.borrowMIKOSEANFTV2(id: nftID) ?? panic("NFT_NOT_FOUND")
    return nft.getRoyaltiesMarket()
}

transaction(nftID: UInt64, salePrice: UFix64, nftversion: String) {
    let holderCap: Capability<&AnyResource{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefrontRef: &MikoSeaMarket.Storefront
    let royalties: MetadataViews.Royalties
    let nftType: Type

    prepare(account: AuthAccount) {
        pre {
            nftversion == "mikosea" || nftversion == "mikoseav2": "nftversion must be mikosea or mikoseav2".concat(", got ").concat(nftversion)
        }

        // setup account
        // for MIKOSAENFTV2
        if account.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath) == nil {
            let collection <- MIKOSEANFTV2.createEmptyCollection()
            account.save(<-collection, to: MIKOSEANFTV2.CollectionStoragePath)
        }
        if (account.getCapability<&MIKOSEANFTV2.Collection{MIKOSEANFTV2.CollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFTV2.CollectionPublicPath).borrow() == nil) {
            account.unlink(MIKOSEANFTV2.CollectionPublicPath)
            account.link<&MIKOSEANFTV2.Collection{MIKOSEANFTV2.CollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFTV2.CollectionPublicPath, target: MIKOSEANFTV2.CollectionStoragePath)
        }
        // for MIKOSAENFT
        if account.borrow<&MIKOSEANFT.Collection>(from: MIKOSEANFT.CollectionStoragePath) == nil {
            let collection <- MIKOSEANFT.createEmptyCollection()
            account.save(<-collection, to: MIKOSEANFT.CollectionStoragePath)
        }
        if (account.getCapability<&MIKOSEANFT.Collection{MIKOSEANFT.MikoSeaCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFT.CollectionPublicPath).borrow() == nil) {
            account.unlink(MIKOSEANFT.CollectionPublicPath)
            account.link<&MIKOSEANFT.Collection{MIKOSEANFT.MikoSeaCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(MIKOSEANFT.CollectionPublicPath, target: MIKOSEANFT.CollectionStoragePath)
        }

        // check and create storefront
        if let storefrontRef = account.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) {
            self.storefrontRef = storefrontRef
        } else {
            let storefront <- MikoSeaMarket.createStorefront()
            let storefrontRef = &storefront as &MikoSeaMarket.Storefront
            account.save(<-storefront, to: MikoSeaMarket.MarketStoragePath)
            account.link<&MikoSeaMarket.Storefront{MikoSeaMarket.StorefrontPublic}>(MikoSeaMarket.MarketPublicPath, target: MikoSeaMarket.MarketStoragePath)
            self.storefrontRef = storefrontRef
        }

        // validate nft
        validateNftExpeiredDate(nftType: nftversion, address: account.address, nftID: nftID)

        if nftversion == "mikosea" {
            // get royalties
            self.royalties = getRoyaltiesV1(address: account.address, nftID: nftID)

            // link private collection
            let MIKOSEANFTPrivatePath = /private/MIKOSEANFTCollection
            if !account.getCapability<&MIKOSEANFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTPrivatePath).check() {
                account.link<&MIKOSEANFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTPrivatePath, target: MIKOSEANFT.CollectionStoragePath)
            }
            self.holderCap = account.getCapability<&MIKOSEANFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTPrivatePath)


            // get nft type
            self.nftType = Type<@MIKOSEANFT.NFT>()
        } else {
            // get royalties
            self.royalties = getRoyaltiesV2(address: account.address, nftID: nftID)

            // link private collection
            let MIKOSEANFTV2PrivatePath = /private/MIKOSEANFTV2Collection
            if !account.getCapability<&MIKOSEANFTV2.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTV2PrivatePath).check() {
                account.link<&MIKOSEANFTV2.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTV2PrivatePath, target: MIKOSEANFTV2.CollectionStoragePath)
            }
            self.holderCap = account.getCapability<&MIKOSEANFTV2.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MIKOSEANFTV2PrivatePath)


            // get nft type
            self.nftType = Type<@MIKOSEANFTV2.NFT>()

            let holder = account.borrow<&MIKOSEANFTV2.Collection>(from: MIKOSEANFTV2.CollectionStoragePath)!
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