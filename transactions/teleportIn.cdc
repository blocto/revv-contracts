import FungibleToken from "../contracts/flow/FungibleToken.cdc"
import REVV from "../contracts/flow/REVV.cdc"
import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(amount: UFix64, target: Address, from: String, hash: String) {
  prepare(teleportAdmin: AuthAccount) {
    let teleportControlRef = teleportAdmin.getCapability(TeleportCustody.TeleportAdminPrivatePath)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportControl}>()
        ?? panic("Could not borrow a reference to TeleportControl")
    
    let vault <- teleportControlRef.teleportIn(amount: amount, from: from.decodeHex(), hash: hash)

    let receiverRef = getAccount(target).getCapability(REVV.RevvReceiverPublicPath)!
        .borrow<&REVV.Vault{FungibleToken.Receiver}>()
        ?? panic("Could not borrow a reference to Receiver")

    receiverRef.deposit(from: <- vault)
  }
}