import FungibleToken from 0xFUNGIBLETOKENADDRESS
import TeleportCustody from 0xREVVTELEPORTCUSTODYADDRESS

transaction {
  prepare(admin: AuthAccount, teleportAdmin: AuthAccount) {

    let adminRef = admin.borrow<&TeleportCustody.Administrator>(from: /storage/revvTeleportCustodyAdmin)
        ?? panic("Could not borrow a reference to the admin resource")

    let teleportAdminRes <- adminRef.createNewTeleportAdmin()

    teleportAdmin.save(<- teleportAdminRes, to: /storage/revvTeleportCustodyTeleportAdmin)

    teleportAdmin.link<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>(
      /public/revvTeleportCustodyTeleportUser,
      target: /storage/revvTeleportCustodyTeleportAdmin
    )

    teleportAdmin.link<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportAdmin}>(
      /private/revvTeleportCustodyTeleportAdmin,
      target: /storage/revvTeleportCustodyTeleportAdmin
    )
  }
}
