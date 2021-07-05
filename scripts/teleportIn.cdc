import FungibleToken from 0xFUNGIBLETOKENADDRESS
import RevvToken from 0xREVVTOKENADDRESS
import TeleportCustody from 0xREVVTELEPORTCUSTODYADDRESS

transaction(amount: UFix64, target: Address, from: String, hash: String) {
  prepare(teleportAdmin: AuthAccount) {
    let teleportControlRef = teleportAdmin.getCapability(/private/revvTeleportCustodyTeleportAdmin)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportControl}>()
        ?? panic("Could not borrow a reference to TeleportControl")
    
    let vault <- teleportControlRef.teleportIn(amount: amount, from: from.decodeHex(), hash: hash)

    let receiverRef = getAccount(target).getCapability(/public/revvTokenReceiver)!
        .borrow<&RevvToken.Vault{FungibleToken.Receiver}>()
        ?? panic("Could not borrow a reference to Receiver")

    receiverRef.deposit(from: <- vault)
  }
}
 