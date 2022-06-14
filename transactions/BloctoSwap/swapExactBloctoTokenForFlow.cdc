import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS
import BloctoToken from 0xBLOCTO_TOKEN_ADDRESS
import FlowToken from 0xFLOW_TOKEN_ADDRESS
import BltUsdtSwapPair from 0xBLT_USDT_SWAP_PAIR_ADDRESS
import FlowSwapPair from 0xFLOW_USDT_SWAP_ADDRESS

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount) {
    
    

    let bloctoTokenVault = signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- bloctoTokenVault.withdraw(amount: amountIn) as! @BloctoToken.Vault
    let token1Vault <- BltUsdtSwapPair.swapToken1ForToken2(from: <- token0Vault)
let token2Vault <- FlowSwapPair.swapToken2ForToken1(from: <- token1Vault)

      if signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) == nil {
    signer.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
    signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(
      /public/flowTokenReceiver,
      target: /storage/flowTokenVault
    )
    signer.link<&FlowToken.Vault{FungibleToken.Balance}>(
      /public/flowTokenBalance,
      target: /storage/flowTokenVault
    )
  }
    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    assert(token2Vault.balance >= minAmountOut, message: "Output amount too small")

    flowTokenVault.deposit(from: <- token2Vault)
  }
}