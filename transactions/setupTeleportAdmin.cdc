import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(amount: UFix64) {
  prepare(admin: AuthAccount, teleportAdmin: AuthAccount) {

    let adminRef = admin.borrow<&TeleportCustody.Administrator>(from: TeleportCustody.AdminStoragePath)
        ?? panic("Could not borrow a reference to the admin resource")

    let teleportAdminRes <- adminRef.createNewTeleportAdmin(allowedAmount: amount)

    teleportAdmin.save(<- teleportAdminRes, to: TeleportCustody.TeleportAdminStoragePath)

    teleportAdmin.link<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>(
      TeleportCustody.TeleportUserPublicPath,
      target: TeleportCustody.TeleportAdminStoragePath
    )

    teleportAdmin.link<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportControl}>(
      TeleportCustody.TeleportAdminPrivatePath,
      target: TeleportCustody.TeleportAdminStoragePath
    )
  }
}
