import FungibleToken from "../contracts/flow/FungibleToken.cdc"
import REVV from "../contracts/flow/REVV.cdc"
import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(teleportAdminAddress: Address, amount: UFix64, target: String) {
  prepare(signer: AuthAccount) {
    let teleportUserRef = getAccount(teleportAdminAddress).getCapability(TeleportCustody.TeleportUserPublicPath)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>()
        ?? panic("Could not borrow a reference to TeleportUser")

    let vaultRef = signer.borrow<&REVV.Vault>(from: REVV.RevvVaultStoragePath)
        ?? panic("Could not borrow a reference to the vault resource")

    let vault <- vaultRef.withdraw(amount: amount) as! @REVV.Vault;
    
    teleportUserRef.teleportOut(from: <- vault, to: target.decodeHex())
  }
}
