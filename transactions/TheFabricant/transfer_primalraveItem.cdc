import NonFungibleToken from 0xNonFungibleToken
    import TheFabricantPrimalRave from 0xHighsnobietyNotInParis

    transaction(recipient: Address, withdrawID: UInt64) {

      prepare(signer: AuthAccount) {
        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a reference to the signer's NFT collection
        let collectionRef = signer
            .borrow<&TheFabricantPrimalRave.Collection>(from: TheFabricantPrimalRave.HighsnobietyNotInParisCollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // borrow a public reference to the receivers collection
        let depositRef = recipient
            .getCapability(TheFabricantPrimalRave.HighsnobietyNotInParisCollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
      }
    }