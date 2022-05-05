import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(inwardFee: UFix64, outwardFee: UFix64) {
  prepare(teleportAdmin: AuthAccount) {
    let teleportAdminRef = teleportAdmin.borrow<&TeleportCustody.TeleportAdmin>(from: TeleportCustody.TeleportAdminStoragePath)
        ?? panic("Could not borrow a reference to the teleport admin resource")
    
    teleportAdminRef.updateInwardFee(fee: inwardFee)
    teleportAdminRef.updateOutwardFee(fee: outwardFee)
  }
}
