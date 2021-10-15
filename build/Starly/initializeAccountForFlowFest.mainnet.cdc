import Beam from 0x86b4a0010a71cfc3
import BlockleteGames_NFT from 0x329feb3ab062d289
import CaaPass from 0x98c9c2e548b84d31
import ChainmonstersRewards from 0x93615d25d14fa337
import Collectible from 0xf5b0eb433389ac3f
import Crave from 0x6d008a788fc27265
import CricketMoments from 0xed398881d9bf40fb
import Everbloom from 0xe703f7fee6400754
import FantastecNFT from 0x2e1ee1e7a96826ce
import FlowToken from 0x1654653399040a61
import FlowStorageFees from 0xe467b9dd11fa00df
import FungibleToken from 0xf233dcee88fe0abe
import FUSD from 0x3c5959b568896393
import Gaia from 0x8b148183c28ff88f
import KlktnNFT from 0xabd6e80be7e9682c
import KOTD from 0x23dddd854fcc8c6f
import MatrixWorldFlowFestNFT from 0x2d2750f240198f91
import MusicBlock from 0x5634aefcb76e7d8c
import Mynft from 0xf6fcbef550d97aa5
import NonFungibleToken from 0x1d7e57aa55817448
import NyatheesOVO from 0x75e0b6de94eb05d0
import RaceDay_NFT from 0x329feb3ab062d289
import RareRooms_NFT from 0x329feb3ab062d289
import RCRDSHPNFT from 0x6c3ff40b90b928ab
import Shard from 0x82b54037a8f180cf
import SportsIconCollectible from 0x8de96244f54db422
import StarlyCard from 0x5b82f21c0edf76e3
import StarlyCardMarket from 0x5b82f21c0edf76e3
import TheFabricantMysteryBox_FF1 from 0xa0cbe021821c0965
import TopShot from 0x0b2a3299cc857e29
import TuneGO from 0x0d9bc5af3fc0c2e3
import Vouchers from 0x444f5ea22c6ea12c

pub fun hasBeam(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Beam.BeamCollectionPublic}>(Beam.CollectionPublicPath)
        .check()
}

pub fun hasBlockleteGames(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&BlockleteGames_NFT.Collection{NonFungibleToken.CollectionPublic,BlockleteGames_NFT.BlockleteGames_NFTCollectionPublic}>(BlockleteGames_NFT.CollectionPublicPath)
        .check()
}

pub fun hasCaaPass(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{NonFungibleToken.CollectionPublic, CaaPass.CollectionPublic}>(CaaPass.CollectionPublicPath)
        .check()
}

pub fun hasChainmonstersRewards(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{ChainmonstersRewards.ChainmonstersRewardCollectionPublic}>(/public/ChainmonstersRewardCollection)
        .check()
}

pub fun hasCrave(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Crave.CraveCollectionPublic}>(Crave.CollectionPublicPath)
        .check()
}

pub fun hasCricketMoments(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&CricketMoments.Collection{NonFungibleToken.CollectionPublic, CricketMoments.CricketMomentsCollectionPublic}>(CricketMoments.CollectionPublicPath)
        .check()
}

pub fun hasEverbloom(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Everbloom.PrintCollectionPublic}>(Everbloom.CollectionPublicPath)
        .check()
}

pub fun hasFantastec(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&FantastecNFT.Collection{NonFungibleToken.CollectionPublic, FantastecNFT.FantastecNFTCollectionPublic}>(FantastecNFT.CollectionPublicPath)
        .check()
}

pub fun hasFUSD(_ address: Address): Bool {
    let receiver: Bool = getAccount(address)
        .getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)
        .check()
    let balance: Bool = getAccount(address)
        .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
        .check()
    return receiver && balance
}

pub fun hasGaia(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Gaia.CollectionPublic}>(Gaia.CollectionPublicPath)
        .check()
}

pub fun hasJambb(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Vouchers.CollectionPublic}>(Vouchers.CollectionPublicPath)
        .check()
}

pub fun hasKLKTN(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&KlktnNFT.Collection{NonFungibleToken.CollectionPublic, KlktnNFT.KlktnNFTCollectionPublic}>(KlktnNFT.CollectionPublicPath)
        .check()
}

pub fun hasKOTD(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{KOTD.NiftoryCollectibleCollectionPublic}>(KOTD.CollectionPublicPath)
        .check()
}

pub fun hasMatrixWorldFlowFestNFT(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&MatrixWorldFlowFestNFT.Collection{NonFungibleToken.CollectionPublic, MatrixWorldFlowFestNFT.MatrixWorldFlowFestNFTCollectionPublic}>(MatrixWorldFlowFestNFT.CollectionPublicPath)
        .check()
}

pub fun hasMusicBlock(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&MusicBlock.Collection{NonFungibleToken.CollectionPublic, MusicBlock.MusicBlockCollectionPublic}>(MusicBlock.CollectionPublicPath)
        .check()
}

pub fun hasMynft(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&Mynft.Collection{Mynft.MynftCollectionPublic}>(Mynft.CollectionPublicPath)
        .check()
}

pub fun hasNyatheesOVO(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&NyatheesOVO.Collection{NonFungibleToken.CollectionPublic, NyatheesOVO.NFTCollectionPublic}>(NyatheesOVO.CollectionPublicPath)
        .check()
}

pub fun hasRaceDay(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&RaceDay_NFT.Collection{NonFungibleToken.CollectionPublic, RaceDay_NFT.RaceDay_NFTCollectionPublic}>(RaceDay_NFT.CollectionPublicPath)
        .check()
}

pub fun hasRareRooms(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&RareRooms_NFT.Collection{NonFungibleToken.CollectionPublic, RareRooms_NFT.RareRooms_NFTCollectionPublic}>(RareRooms_NFT.CollectionPublicPath)
        .check()
}

pub fun hasRCRDSHPNFT(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{NonFungibleToken.CollectionPublic}>(RCRDSHPNFT.collectionPublicPath)
        .check()
}

pub fun hasShard(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Shard.ShardCollectionPublic}>(/public/EternalShardCollection)
        .check()
}

pub fun hasSportsIcon(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&SportsIconCollectible.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, SportsIconCollectible.CollectibleCollectionPublic}>(SportsIconCollectible.CollectionPublicPath)
        .check()
}

pub fun hasStarlyCard(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&StarlyCard.Collection{NonFungibleToken.CollectionPublic, StarlyCard.StarlyCardCollectionPublic}>(StarlyCard.CollectionPublicPath)
        .check()
}

pub fun hasStarlyCardMarket(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(StarlyCardMarket.CollectionPublicPath)
        .check()
}

pub fun hasTheFabricant(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{TheFabricantMysteryBox_FF1.FabricantCollectionPublic}>(TheFabricantMysteryBox_FF1.CollectionPublicPath)
        .check()
}

pub fun hasTopShot(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{TopShot.MomentCollectionPublic}>(/public/MomentCollection)
        .check()
}

pub fun hasTuneGO(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{TuneGO.TuneGOCollectionPublic}>(TuneGO.CollectionPublicPath)
        .check()
}

pub fun hasXtingles(_ address: Address): Bool {
    return getAccount(address)
        .getCapability<&{Collectible.CollectionPublic}>(Collectible.CollectionPublicPath)
        .check()
}

transaction {
    prepare(acct: AuthAccount, admin: AuthAccount) {
        if !hasBeam(acct.address) {
             if acct.borrow<&Beam.Collection>(from: Beam.CollectionStoragePath) == nil {
                 acct.save(<-Beam.createEmptyCollection(), to: Beam.CollectionStoragePath)
             }
             acct.link<&{Beam.BeamCollectionPublic}>(Beam.CollectionPublicPath, target: Beam.CollectionStoragePath)
        }
        if !hasBlockleteGames(acct.address) {
             if acct.borrow<&BlockleteGames_NFT.Collection>(from: BlockleteGames_NFT.CollectionStoragePath) == nil {
                 acct.save(<-BlockleteGames_NFT.createEmptyCollection(), to: BlockleteGames_NFT.CollectionStoragePath)
             }
             acct.link<&BlockleteGames_NFT.Collection{NonFungibleToken.CollectionPublic,BlockleteGames_NFT.BlockleteGames_NFTCollectionPublic}>(BlockleteGames_NFT.CollectionPublicPath, target: BlockleteGames_NFT.CollectionStoragePath)
        }
        if !hasCaaPass(acct.address) {
             if acct.borrow<&CaaPass.Collection>(from: CaaPass.CollectionStoragePath) == nil {
                 acct.save(<-CaaPass.createEmptyCollection(), to: CaaPass.CollectionStoragePath)
             }
             acct.link<&{NonFungibleToken.CollectionPublic, CaaPass.CollectionPublic}>(CaaPass.CollectionPublicPath, target: CaaPass.CollectionStoragePath)
        }
        if !hasChainmonstersRewards(acct.address) {
             if acct.borrow<&ChainmonstersRewards.Collection>(from: /storage/ChainmonstersRewardCollection) == nil {
                 acct.save(<-ChainmonstersRewards.createEmptyCollection(), to: /storage/ChainmonstersRewardCollection)
             }
             acct.link<&{ChainmonstersRewards.ChainmonstersRewardCollectionPublic}>(/public/ChainmonstersRewardCollection, target: /storage/ChainmonstersRewardCollection)
        }
        if !hasCrave(acct.address) {
             if acct.borrow<&Crave.Collection>(from: Crave.CollectionStoragePath) == nil {
                 acct.save(<-Crave.createEmptyCollection(), to: Crave.CollectionStoragePath)
             }
             acct.link<&{Crave.CraveCollectionPublic}>(Crave.CollectionPublicPath, target: Crave.CollectionStoragePath)
        }
        if !hasCricketMoments(acct.address) {
             if acct.borrow<&CricketMoments.Collection>(from: CricketMoments.CollectionStoragePath) == nil {
                 acct.save(<-CricketMoments.createEmptyCollection(), to: CricketMoments.CollectionStoragePath)
             }
             acct.link<&CricketMoments.Collection{NonFungibleToken.CollectionPublic, CricketMoments.CricketMomentsCollectionPublic}>(CricketMoments.CollectionPublicPath, target: CricketMoments.CollectionStoragePath)
        }
        if !hasEverbloom(acct.address) {
             if acct.borrow<&Everbloom.Collection>(from: Everbloom.CollectionStoragePath) == nil {
                 acct.save(<-Everbloom.createEmptyCollection(), to: Everbloom.CollectionStoragePath)
             }
             acct.link<&{Everbloom.PrintCollectionPublic}>(Everbloom.CollectionPublicPath, target: Everbloom.CollectionStoragePath)
        }
        if !hasFantastec(acct.address) {
             if acct.borrow<&FantastecNFT.Collection>(from: FantastecNFT.CollectionStoragePath) == nil {
                 acct.save(<-FantastecNFT.createEmptyCollection(), to: FantastecNFT.CollectionStoragePath)
             }
             acct.link<&FantastecNFT.Collection{NonFungibleToken.CollectionPublic, FantastecNFT.FantastecNFTCollectionPublic}>(FantastecNFT.CollectionPublicPath, target: FantastecNFT.CollectionStoragePath)
        }
        if !hasFUSD(acct.address) {
            if acct.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil {
                acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            }
            acct.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            acct.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }
        if !hasGaia(acct.address) {
            if acct.borrow<&Gaia.Collection>(from: Gaia.CollectionStoragePath) == nil {
                acct.save(<-Gaia.createEmptyCollection(), to: Gaia.CollectionStoragePath)
            }
            acct.link<&{Gaia.CollectionPublic}>(Gaia.CollectionPublicPath, target: Gaia.CollectionStoragePath)
        }
        if !hasJambb(acct.address) {
             if acct.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath) == nil {
                 acct.save(<-Vouchers.createEmptyCollection(), to: Vouchers.CollectionStoragePath)
             }
             acct.link<&{Vouchers.CollectionPublic}>(Vouchers.CollectionPublicPath, target: Vouchers.CollectionStoragePath)
        }
        if !hasKLKTN(acct.address) {
             if acct.borrow<&KlktnNFT.Collection>(from: KlktnNFT.CollectionStoragePath) == nil {
                 acct.save(<-KlktnNFT.createEmptyCollection(), to: KlktnNFT.CollectionStoragePath)
             }
             acct.link<&KlktnNFT.Collection{NonFungibleToken.CollectionPublic, KlktnNFT.KlktnNFTCollectionPublic}>(KlktnNFT.CollectionPublicPath, target: KlktnNFT.CollectionStoragePath)
        }
        if !hasKOTD(acct.address) {
             if acct.borrow<&KOTD.Collection>(from: KOTD.CollectionStoragePath) == nil {
                 acct.save(<-KOTD.createEmptyCollection(), to: KOTD.CollectionStoragePath)
             }
             acct.link<&{KOTD.NiftoryCollectibleCollectionPublic}>(KOTD.CollectionPublicPath, target: KOTD.CollectionStoragePath)
        }
        if !hasMatrixWorldFlowFestNFT(acct.address) {
             if acct.borrow<&MatrixWorldFlowFestNFT.Collection>(from: MatrixWorldFlowFestNFT.CollectionStoragePath) == nil {
                 acct.save(<-MatrixWorldFlowFestNFT.createEmptyCollection(), to: MatrixWorldFlowFestNFT.CollectionStoragePath)
             }
             acct.link<&MatrixWorldFlowFestNFT.Collection{NonFungibleToken.CollectionPublic, MatrixWorldFlowFestNFT.MatrixWorldFlowFestNFTCollectionPublic}>(MatrixWorldFlowFestNFT.CollectionPublicPath, target: MatrixWorldFlowFestNFT.CollectionStoragePath)
        }
        if !hasMusicBlock(acct.address) {
             if acct.borrow<&MusicBlock.Collection>(from: MusicBlock.CollectionStoragePath) == nil {
                 acct.save(<-MusicBlock.createEmptyCollection(), to: MusicBlock.CollectionStoragePath)
             }
             acct.link<&MusicBlock.Collection{NonFungibleToken.CollectionPublic, MusicBlock.MusicBlockCollectionPublic}>(MusicBlock.CollectionPublicPath, target: MusicBlock.CollectionStoragePath)
        }
        if !hasMynft(acct.address) {
             if acct.borrow<&Mynft.Collection>(from: Mynft.CollectionStoragePath) == nil {
                 acct.save(<-Mynft.createEmptyCollection(), to: Mynft.CollectionStoragePath)
             }
             acct.link<&Mynft.Collection{NonFungibleToken.CollectionPublic, Mynft.MynftCollectionPublic}>(Mynft.CollectionPublicPath, target: Mynft.CollectionStoragePath)
        }
        if !hasNyatheesOVO(acct.address) {
             if acct.borrow<&NyatheesOVO.Collection>(from: NyatheesOVO.CollectionStoragePath) == nil {
                 acct.save(<-NyatheesOVO.createEmptyCollection(), to: NyatheesOVO.CollectionStoragePath)
             }
             acct.link<&NyatheesOVO.Collection{NonFungibleToken.CollectionPublic, NyatheesOVO.NFTCollectionPublic}>(NyatheesOVO.CollectionPublicPath, target: NyatheesOVO.CollectionStoragePath)
        }
        if !hasRaceDay(acct.address) {
             if acct.borrow<&RaceDay_NFT.Collection>(from: RaceDay_NFT.CollectionStoragePath) == nil {
                 acct.save(<-RaceDay_NFT.createEmptyCollection(), to: RaceDay_NFT.CollectionStoragePath)
             }
             acct.link<&RaceDay_NFT.Collection{NonFungibleToken.CollectionPublic, RaceDay_NFT.RaceDay_NFTCollectionPublic}>(RaceDay_NFT.CollectionPublicPath, target: RaceDay_NFT.CollectionStoragePath)
        }
        if !hasRareRooms(acct.address) {
             if acct.borrow<&RareRooms_NFT.Collection>(from: RareRooms_NFT.CollectionStoragePath) == nil {
                 acct.save(<-RareRooms_NFT.createEmptyCollection(), to: RareRooms_NFT.CollectionStoragePath)
             }
             acct.link<&RareRooms_NFT.Collection{NonFungibleToken.CollectionPublic, RareRooms_NFT.RareRooms_NFTCollectionPublic}>(RareRooms_NFT.CollectionPublicPath, target: RareRooms_NFT.CollectionStoragePath)
        }
        if !hasRCRDSHPNFT(acct.address) {
             if acct.borrow<&RCRDSHPNFT.Collection>(from: RCRDSHPNFT.collectionStoragePath) == nil {
                 acct.save(<-RCRDSHPNFT.createEmptyCollection(), to: RCRDSHPNFT.collectionStoragePath)
             }
             acct.link<&{NonFungibleToken.CollectionPublic}>(RCRDSHPNFT.collectionPublicPath, target: RCRDSHPNFT.collectionStoragePath)
        }
        if !hasShard(acct.address) {
             if acct.borrow<&Shard.Collection>(from: /storage/EternalShardCollection) == nil {
                 acct.save(<-Shard.createEmptyCollection(), to: /storage/EternalShardCollection)
             }
             acct.link<&{Shard.ShardCollectionPublic}>(/public/EternalShardCollection, target: /storage/EternalShardCollection)
        }
        if !hasSportsIcon(acct.address) {
             if acct.borrow<&SportsIconCollectible.Collection>(from: SportsIconCollectible.CollectionStoragePath) == nil {
                 acct.save(<-SportsIconCollectible.createEmptyCollection(), to: SportsIconCollectible.CollectionStoragePath)
             }
             acct.link<&SportsIconCollectible.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, SportsIconCollectible.CollectibleCollectionPublic}>(SportsIconCollectible.CollectionPublicPath, target: SportsIconCollectible.CollectionStoragePath)
        }
        if !hasStarlyCard(acct.address) {
            if acct.borrow<&StarlyCard.Collection>(from: StarlyCard.CollectionStoragePath) == nil {
                acct.save(<-StarlyCard.createEmptyCollection(), to: StarlyCard.CollectionStoragePath)
            }
            acct.link<&StarlyCard.Collection{NonFungibleToken.CollectionPublic, StarlyCard.StarlyCardCollectionPublic}>(StarlyCard.CollectionPublicPath, target: StarlyCard.CollectionStoragePath)
        }
        if !hasStarlyCardMarket(acct.address) {
             if acct.borrow<&StarlyCardMarket.Collection>(from: StarlyCardMarket.CollectionStoragePath) == nil {
                 acct.save(<-StarlyCardMarket.createEmptyCollection(), to: StarlyCardMarket.CollectionStoragePath)
             }
             acct.link<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(StarlyCardMarket.CollectionPublicPath, target: StarlyCardMarket.CollectionStoragePath)
        }
        if !hasTheFabricant(acct.address) {
             if acct.borrow<&TheFabricantMysteryBox_FF1.Collection>(from: TheFabricantMysteryBox_FF1.CollectionStoragePath) == nil {
                 acct.save(<-TheFabricantMysteryBox_FF1.createEmptyCollection(), to: TheFabricantMysteryBox_FF1.CollectionStoragePath)
             }
             acct.link<&{TheFabricantMysteryBox_FF1.FabricantCollectionPublic}>(TheFabricantMysteryBox_FF1.CollectionPublicPath, target: TheFabricantMysteryBox_FF1.CollectionStoragePath)
        }
        if !hasTopShot(acct.address) {
             if acct.borrow<&TopShot.Collection>(from: /storage/MomentCollection) == nil {
                 acct.save(<-TopShot.createEmptyCollection(), to: /storage/MomentCollection)
             }
             acct.link<&{TopShot.MomentCollectionPublic}>(/public/MomentCollection, target: /storage/MomentCollection)
        }
        if !hasTuneGO(acct.address) {
             if acct.borrow<&TuneGO.Collection>(from: TuneGO.CollectionStoragePath) == nil {
                 acct.save(<-TuneGO.createEmptyCollection(), to: TuneGO.CollectionStoragePath)
             }
             acct.link<&{TuneGO.TuneGOCollectionPublic}>(TuneGO.CollectionPublicPath, target: TuneGO.CollectionStoragePath)
        }
        if !hasXtingles(acct.address) {
             if acct.borrow<&Collectible.Collection>(from: Collectible.CollectionStoragePath) == nil {
                 acct.save(<-Collectible.createEmptyCollection(), to: Collectible.CollectionStoragePath)
             }
             acct.link<&{Collectible.CollectionPublic}>(Collectible.CollectionPublicPath, target: Collectible.CollectionStoragePath)
        }

        fun returnFlowFromStorage(_ storage: UInt64): UFix64 {
            let f = UFix64(storage % 100000000 as UInt64) * 0.00000001 as UFix64 + UFix64(storage / 100000000 as UInt64)
            let storageMb = f * 100.0 as UFix64
            let storage = FlowStorageFees.storageCapacityToFlow(storageMb)
            return storage
        }

        var storageUsed = returnFlowFromStorage(acct.storageUsed) + 0.0005
        var storageTotal = returnFlowFromStorage(acct.storageCapacity)
        if (storageUsed > storageTotal) {
            let difference = storageUsed - storageTotal
            let vaultRef = admin.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ?? panic("Could not borrow reference to the admin's Vault!")
            let sentVault <- vaultRef.withdraw(amount: difference)
            let receiver = acct.getCapability(/public/flowTokenReceiver).borrow<&{FungibleToken.Receiver}>()
                ?? panic("failed to borrow reference to recipient vault")
            receiver.deposit(from: <-sentVault)
        }
    }
}