import TeleportCustody from 0xREVVTELEPORTCUSTODYADDRESS

transaction(teleportAdmin: Address, allowedAmount: UFix64) {
  prepare(admin: AuthAccount) {

    let adminRef = admin.borrow<&TeleportCustody.Administrator>(from: /storage/revvTeleportCustodyAdmin)
        ?? panic("Could not borrow a reference to the admin resource")

    let allowance <- adminRef.createAllowance(allowedAmount: allowedAmount)

    let teleportUserRef = getAccount(teleportAdmin).getCapability(/public/revvTeleportCustodyTeleportUser)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>()
        ?? panic("Could not borrow a reference to TeleportUser")

    teleportUserRef.depositAllowance(from: <- allowance)
  }
}
