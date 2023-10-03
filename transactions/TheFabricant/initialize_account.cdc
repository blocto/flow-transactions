import FBRC from 0xFBRC
import FlowToken from 0xFlowToken
import FungibleToken from 0xFungibleToken
import GarmentNFT from 0xGarmentNFT
import MaterialNFT from 0xMaterialNFT
import ItemNFT from 0xItemNFT
import TheFabricantS1GarmentNFT from 0xTheFabricantS1GarmentNFT
import TheFabricantS1MaterialNFT from 0xTheFabricantS1MaterialNFT
import TheFabricantS1ItemNFT from 0xTheFabricantS1ItemNFT
import TheFabricantS2GarmentNFT from 0xTheFabricantS2GarmentNFT
import TheFabricantS2MaterialNFT from 0xTheFabricantS2MaterialNFT
import TheFabricantS2ItemNFT from 0xTheFabricantS2ItemNFT
import TheFabricantMysteryBox_FF1 from 0xTheFabricantMysteryBox_FF1
import DieselNFT from 0xDieselNFT
import MiamiNFT from 0xMiamiNFT
import NonFungibleToken from 0xNonFungibleToken
import TheFabricantAccessPass from 0xTheFabricantAccessPass
import TheFabricantXXories from 0xTheFabricantXXories
import MetadataViews from 0xMetadataViews
import TheFabricantKapers from 0xTheFabricantKapers
import Weekday from 0xWeekday
import HighsnobietyNotInParis from 0xHighsnobietyNotInParis
import TheFabricantPrimalRave from 0xTheFabricantPrimalRave

// initializes NFT and FT collections if not already done so
transaction() {

    prepare(acct: AuthAccount) {

        // initialize FBRC
        if !( acct.getCapability<&FBRC.Vault{FungibleToken.Receiver}>(FBRC.CollectionReceiverPath).check() 
        && acct.getCapability<&FBRC.Vault{FungibleToken.Balance}>(FBRC.CollectionBalancePath).check()) {
            if acct.type(at: FBRC.CollectionStoragePath) == nil {
                acct.save(<-FBRC.createEmptyVault(), to: FBRC.CollectionStoragePath)
            }
            acct.unlink(FBRC.CollectionReceiverPath)
            acct.unlink(FBRC.CollectionBalancePath)
            acct.link<&FBRC.Vault{FungibleToken.Receiver}>(FBRC.CollectionReceiverPath, target: FBRC.CollectionStoragePath)
            acct.link<&FBRC.Vault{FungibleToken.Balance}>(FBRC.CollectionBalancePath, target: FBRC.CollectionStoragePath)
        }

        // initialize GarmentNFT
        if !acct.getCapability<&GarmentNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, GarmentNFT.GarmentCollectionPublic}>(GarmentNFT.CollectionPublicPath).check() {
            if acct.type(at: GarmentNFT.CollectionStoragePath) == nil {
                let collection <- GarmentNFT.createEmptyCollection() as! @GarmentNFT.Collection
                acct.save(<-collection, to: GarmentNFT.CollectionStoragePath)
            }
            acct.unlink(GarmentNFT.CollectionPublicPath)
            acct.link<&GarmentNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, GarmentNFT.GarmentCollectionPublic}>(GarmentNFT.CollectionPublicPath, target: GarmentNFT.CollectionStoragePath)
        }

        // initialize MaterialNFT
        if !acct.getCapability<&MaterialNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MaterialNFT.MaterialCollectionPublic}>(MaterialNFT.CollectionPublicPath).check() {
            if acct.type(at: MaterialNFT.CollectionStoragePath) == nil {
                let collection <- MaterialNFT.createEmptyCollection() as! @MaterialNFT.Collection
                acct.save(<-collection, to: MaterialNFT.CollectionStoragePath)
            }
            acct.unlink(MaterialNFT.CollectionPublicPath)
            acct.link<&MaterialNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MaterialNFT.MaterialCollectionPublic}>(MaterialNFT.CollectionPublicPath, target: MaterialNFT.CollectionStoragePath)
        }

        // initialize ItemNFT 
        if !acct.getCapability<&ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, ItemNFT.ItemCollectionPublic}>(ItemNFT.CollectionPublicPath).check() {
            if acct.type(at: ItemNFT.CollectionStoragePath) == nil {
                let collection <- ItemNFT.createEmptyCollection() as! @ItemNFT.Collection
                acct.save(<-collection, to: ItemNFT.CollectionStoragePath)
            }
            acct.unlink(ItemNFT.CollectionPublicPath)
            acct.link<&ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, ItemNFT.ItemCollectionPublic}>(ItemNFT.CollectionPublicPath, target: ItemNFT.CollectionStoragePath)
        }

        // initialize S1GarmentNFT
        if !acct.getCapability<&TheFabricantS1GarmentNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS1GarmentNFT.GarmentCollectionPublic}>(TheFabricantS1GarmentNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS1GarmentNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS1GarmentNFT.createEmptyCollection() as! @TheFabricantS1GarmentNFT.Collection
                acct.save(<-collection, to: TheFabricantS1GarmentNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS1GarmentNFT.CollectionPublicPath)
            acct.link<&TheFabricantS1GarmentNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS1GarmentNFT.GarmentCollectionPublic}>(TheFabricantS1GarmentNFT.CollectionPublicPath, target: TheFabricantS1GarmentNFT.CollectionStoragePath)
        }

        // initialize S1MaterialNFT
        if !acct.getCapability<&TheFabricantS1MaterialNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS1MaterialNFT.MaterialCollectionPublic}>(TheFabricantS1MaterialNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS1MaterialNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS1MaterialNFT.createEmptyCollection() as! @TheFabricantS1MaterialNFT.Collection
                acct.save(<-collection, to: TheFabricantS1MaterialNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS1MaterialNFT.CollectionPublicPath)
            acct.link<&TheFabricantS1MaterialNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS1MaterialNFT.MaterialCollectionPublic}>(TheFabricantS1MaterialNFT.CollectionPublicPath, target: TheFabricantS1MaterialNFT.CollectionStoragePath)
        }

        // initialize S1ItemNFT
        if !acct.getCapability<&TheFabricantS1ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS1ItemNFT.ItemCollectionPublic}>(TheFabricantS1ItemNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS1ItemNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS1ItemNFT.createEmptyCollection() as! @TheFabricantS1ItemNFT.Collection
                acct.save(<-collection, to: TheFabricantS1ItemNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS1ItemNFT.CollectionPublicPath)
            acct.link<&TheFabricantS1ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS1ItemNFT.ItemCollectionPublic}>(TheFabricantS1ItemNFT.CollectionPublicPath, target: TheFabricantS1ItemNFT.CollectionStoragePath)
        }

        // initialize S2GarmentNFT
        if !acct.getCapability<&TheFabricantS2GarmentNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS2GarmentNFT.GarmentCollectionPublic}>(TheFabricantS2GarmentNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS2GarmentNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS2GarmentNFT.createEmptyCollection() as! @TheFabricantS2GarmentNFT.Collection
                acct.save(<-collection, to: TheFabricantS2GarmentNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS2GarmentNFT.CollectionPublicPath)
            acct.link<&TheFabricantS2GarmentNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS2GarmentNFT.GarmentCollectionPublic}>(TheFabricantS2GarmentNFT.CollectionPublicPath, target: TheFabricantS2GarmentNFT.CollectionStoragePath)
        }

        // initialize S2MaterialNFT
        if !acct.getCapability<&TheFabricantS2MaterialNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS2MaterialNFT.MaterialCollectionPublic}>(TheFabricantS2MaterialNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS2MaterialNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS2MaterialNFT.createEmptyCollection() as! @TheFabricantS2MaterialNFT.Collection
                acct.save(<-collection, to: TheFabricantS2MaterialNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS2MaterialNFT.CollectionPublicPath)
            acct.link<&TheFabricantS2MaterialNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS2MaterialNFT.MaterialCollectionPublic}>(TheFabricantS2MaterialNFT.CollectionPublicPath, target: TheFabricantS2MaterialNFT.CollectionStoragePath)
        }

        // initialize S2ItemNFT
        if !acct.getCapability<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS2ItemNFT.ItemCollectionPublic}>(TheFabricantS2ItemNFT.CollectionPublicPath).check() {
            if acct.type(at: TheFabricantS2ItemNFT.CollectionStoragePath) == nil {
                let collection <- TheFabricantS2ItemNFT.createEmptyCollection() as! @TheFabricantS2ItemNFT.Collection
                acct.save(<-collection, to: TheFabricantS2ItemNFT.CollectionStoragePath)
            }
            acct.unlink(TheFabricantS2ItemNFT.CollectionPublicPath)
            acct.link<&TheFabricantS2ItemNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantS2ItemNFT.ItemCollectionPublic}>(TheFabricantS2ItemNFT.CollectionPublicPath, target: TheFabricantS2ItemNFT.CollectionStoragePath)
        }

        // initialize TheFabricantMysteryBox_FF1
        if !acct.getCapability<&TheFabricantMysteryBox_FF1.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantMysteryBox_FF1.FabricantCollectionPublic}>(TheFabricantMysteryBox_FF1.CollectionPublicPath).check(){
            if acct.type(at: TheFabricantMysteryBox_FF1.CollectionStoragePath) == nil {
                let collection <- TheFabricantMysteryBox_FF1.createEmptyCollection() as! @TheFabricantMysteryBox_FF1.Collection
                acct.save(<-collection, to: TheFabricantMysteryBox_FF1.CollectionStoragePath)
            }
            acct.unlink(TheFabricantMysteryBox_FF1.CollectionPublicPath)
            acct.link<&TheFabricantMysteryBox_FF1.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantMysteryBox_FF1.FabricantCollectionPublic}>(TheFabricantMysteryBox_FF1.CollectionPublicPath, target: TheFabricantMysteryBox_FF1.CollectionStoragePath)
        }  

        // initialize DieselNFT
        if !acct.getCapability<&DieselNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, DieselNFT.DieselCollectionPublic}>(DieselNFT.CollectionPublicPath) .check() {
            if acct.type(at: DieselNFT.CollectionStoragePath) == nil {
                let collection <- DieselNFT.createEmptyCollection() as! @DieselNFT.Collection
                acct.save(<-collection, to: DieselNFT.CollectionStoragePath)
            }
            acct.unlink(DieselNFT.CollectionPublicPath)
            acct.link<&DieselNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, DieselNFT.DieselCollectionPublic}>(DieselNFT.CollectionPublicPath, target: DieselNFT.CollectionStoragePath)
        }  

        // initialize MiamiNFT
        if !acct.getCapability<&MiamiNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MiamiNFT.MiamiCollectionPublic}>(MiamiNFT.CollectionPublicPath).check(){
            if acct.type(at: MiamiNFT.CollectionStoragePath) == nil {
                let collection <- MiamiNFT.createEmptyCollection() as! @MiamiNFT.Collection
                acct.save(<-collection, to: MiamiNFT.CollectionStoragePath)
            }
            acct.unlink(MiamiNFT.CollectionPublicPath)
            acct.link<&MiamiNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MiamiNFT.MiamiCollectionPublic}>(MiamiNFT.CollectionPublicPath, target: MiamiNFT.CollectionStoragePath)
        }
        
        // initialize AccessPass
        if !(acct.getCapability<&TheFabricantAccessPass.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantAccessPass.TheFabricantAccessPassCollectionPublic}>(TheFabricantAccessPass.TheFabricantAccessPassCollectionPublicPath).check()) {
            if acct.type(at: TheFabricantAccessPass.TheFabricantAccessPassCollectionStoragePath) == nil {
                let collection <- TheFabricantAccessPass.createEmptyCollection() as! @TheFabricantAccessPass.Collection
                acct.save(<- collection, to: TheFabricantAccessPass.TheFabricantAccessPassCollectionStoragePath)
            }
            acct.unlink(TheFabricantAccessPass.TheFabricantAccessPassCollectionPublicPath)
            acct.link<&TheFabricantAccessPass.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantAccessPass.TheFabricantAccessPassCollectionPublic}>(TheFabricantAccessPass.TheFabricantAccessPassCollectionPublicPath, target: TheFabricantAccessPass.TheFabricantAccessPassCollectionStoragePath)
        } 

        // initialize XXory
        if !(acct.getCapability<&TheFabricantXXories.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantXXories.TheFabricantXXoriesCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantXXories.TheFabricantXXoriesCollectionPublicPath).check()) {
            if acct.type(at: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath) == nil {
                let collection <- TheFabricantXXories.createEmptyCollection() as! @TheFabricantXXories.Collection
                acct.save(<- collection, to: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath)
            }
            acct.unlink(TheFabricantXXories.TheFabricantXXoriesCollectionPublicPath)
            acct.link<&TheFabricantXXories.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantXXories.TheFabricantXXoriesCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantXXories.TheFabricantXXoriesCollectionPublicPath, target: TheFabricantXXories.TheFabricantXXoriesCollectionStoragePath)
        } 

        // initialize Kapers
        if !(acct.getCapability<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantKapers.TheFabricantKapersCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath).check()) {
            if acct.type(at: TheFabricantKapers.TheFabricantKapersCollectionStoragePath) == nil {
                let collection <- TheFabricantKapers.createEmptyCollection() as! @TheFabricantKapers.Collection
                acct.save(<- collection, to: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
            }
            acct.unlink(TheFabricantKapers.TheFabricantKapersCollectionPublicPath)
            acct.link<&TheFabricantKapers.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantKapers.TheFabricantKapersCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantKapers.TheFabricantKapersCollectionPublicPath, target: TheFabricantKapers.TheFabricantKapersCollectionStoragePath)
        }

        // initialize Weekday
        if !(acct.getCapability<&Weekday.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Weekday.WeekdayCollectionPublic, MetadataViews.ResolverCollection}>(Weekday.WeekdayCollectionPublicPath).check()) {
            if acct.type(at: Weekday.WeekdayCollectionStoragePath) == nil {
                let collection <- Weekday.createEmptyCollection() as! @Weekday.Collection
                acct.save(<- collection, to: Weekday.WeekdayCollectionStoragePath)
            }
            acct.unlink(Weekday.WeekdayCollectionPublicPath)
            acct.link<&Weekday.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Weekday.WeekdayCollectionPublic, MetadataViews.ResolverCollection}>(Weekday.WeekdayCollectionPublicPath, target: Weekday.WeekdayCollectionStoragePath)
        }

        // initialize HighsnobietyNotInParis
        if !(acct.getCapability<&HighsnobietyNotInParis.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, HighsnobietyNotInParis.HighsnobietyNotInParisCollectionPublic, MetadataViews.ResolverCollection}>(HighsnobietyNotInParis.HighsnobietyNotInParisCollectionPublicPath).check()) {
            if acct.type(at: HighsnobietyNotInParis.HighsnobietyNotInParisCollectionStoragePath) == nil {
                let collection <- HighsnobietyNotInParis.createEmptyCollection() as! @HighsnobietyNotInParis.Collection
                acct.save(<- collection, to: HighsnobietyNotInParis.HighsnobietyNotInParisCollectionStoragePath)
            }
            acct.unlink(HighsnobietyNotInParis.HighsnobietyNotInParisCollectionPublicPath)
            acct.link<&HighsnobietyNotInParis.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, HighsnobietyNotInParis.HighsnobietyNotInParisCollectionPublic, MetadataViews.ResolverCollection}>(HighsnobietyNotInParis.HighsnobietyNotInParisCollectionPublicPath, target: HighsnobietyNotInParis.HighsnobietyNotInParisCollectionStoragePath)
        }

        // initialize TheFabricantPrimalRave
        if !(acct.getCapability<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath).check()) {
            if acct.type(at: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath) == nil {
                let collection <- TheFabricantPrimalRave.createEmptyCollection() as! @TheFabricantPrimalRave.Collection
                acct.save(<- collection, to: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
            }
            acct.unlink(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath)
            acct.link<&TheFabricantPrimalRave.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublic, MetadataViews.ResolverCollection}>(TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionPublicPath, target: TheFabricantPrimalRave.TheFabricantPrimalRaveCollectionStoragePath)
        }
    }
    
}