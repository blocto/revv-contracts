import FungibleToken from "../contracts/flow/FungibleToken.cdc"
import RevvToken from "../contracts/flow/RevvToken.cdc"
import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(teleportAdminAddress: Address, amount: UFix64, target: String) {
  prepare(signer: AuthAccount) {
    let teleportUserRef = getAccount(teleportAdminAddress).getCapability(TeleportCustody.TeleportUserPublicPath)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>()
        ?? panic("Could not borrow a reference to TeleportUser")

    let vaultRef = signer.borrow<&RevvToken.Vault>(from: RevvToken.RevvTokenVaultStoragePath)
        ?? panic("Could not borrow a reference to the vault resource")

    let vault <- vaultRef.withdraw(amount: amount) as! @RevvToken.Vault;
    
    teleportUserRef.teleportOut(from: <- vault, to: target.decodeHex())
  }
}
