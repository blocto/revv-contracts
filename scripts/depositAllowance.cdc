import TeleportCustody from 0xREVVTELEPORTCUSTODYADDRESS

transaction(teleportAdmin: Address, allowedAmount: UFix64) {
  prepare(admin: AuthAccount) {

    let adminRef = admin.borrow<&TeleportCustody.Administrator>(from: TeleportCustody.AdminStoragePath)
        ?? panic("Could not borrow a reference to the admin resource")

    let allowance <- adminRef.createAllowance(allowedAmount: allowedAmount)

    let teleportUserRef = getAccount(teleportAdmin).getCapability(TeleportCustody.TeleportUserPublicPath)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>()
        ?? panic("Could not borrow a reference to TeleportUser")

    teleportUserRef.depositAllowance(from: <- allowance)
  }
}
