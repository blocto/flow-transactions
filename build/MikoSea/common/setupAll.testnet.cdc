// setup collection all v3.0
import MIKOSEANFT from 0x713306ac51ac7ddb
import MIKOSEANFTV2 from 0x713306ac51ac7ddb
import MetadataViews from 0x631e88ae7f1d7c20
import MikoSeaMarket from 0x713306ac51ac7ddb

transaction {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        // for MIKOSAENFT
        let mikoseaCollectionData = MIKOSEANFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Return early if the account already has a collection
        if signer.storage.borrow<&MIKOSEANFT.Collection>(from: mikoseaCollectionData.storagePath) == nil {
            // Create a new empty collection
            let collection <- MIKOSEANFT.createEmptyCollection(nftType: Type<@MIKOSEANFT.NFT>())

            // save it to the account
            signer.storage.save(<-collection, to: mikoseaCollectionData.storagePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(mikoseaCollectionData.publicPath)
            let collectionCap = signer.capabilities.storage.issue<&MIKOSEANFT.Collection>(mikoseaCollectionData.storagePath)
            signer.capabilities.publish(collectionCap, at: mikoseaCollectionData.publicPath)
        }

        // for MIKOSAENFTV2
        let mikoseav2CollectionData = MIKOSEANFTV2.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Return early if the account already has a collection
        if signer.storage.borrow<&MIKOSEANFTV2.Collection>(from: mikoseav2CollectionData.storagePath) == nil {
            // Create a new empty collection
            let collection <- MIKOSEANFTV2.createEmptyCollection(nftType: Type<@MIKOSEANFTV2.NFT>())

            // save it to the account
            signer.storage.save(<-collection, to: mikoseav2CollectionData.storagePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(mikoseav2CollectionData.publicPath)
            let collectionCap = signer.capabilities.storage.issue<&MIKOSEANFTV2.Collection>(mikoseav2CollectionData.storagePath)
            signer.capabilities.publish(collectionCap, at: mikoseav2CollectionData.publicPath)
        }

        // for storefont
        if signer.storage.borrow<&MikoSeaMarket.Storefront>(from: MikoSeaMarket.MarketStoragePath) == nil {
            // Create a new empty collection
            let storefront <- MikoSeaMarket.createStorefront()

            // save it to the account
            signer.storage.save(<-storefront, to: MikoSeaMarket.MarketStoragePath)

            // create a public capability for the collection
            signer.capabilities.unpublish(MikoSeaMarket.MarketPublicPath)
            signer.capabilities.publish(signer.capabilities.storage.issue<&MikoSeaMarket.Storefront>(MikoSeaMarket.MarketStoragePath), at: MikoSeaMarket.MarketPublicPath)
        }
    }
}