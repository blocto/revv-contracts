import RevvToken from "../contracts/flow/RevvToken.cdc"
import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(amount: UFix64) {
  prepare(admin: AuthAccount) {

    let adminRef = admin.borrow<&TeleportCustody.Administrator>(from: TeleportCustody.AdminStoragePath)
      ?? panic("Could not borrow a reference to the admin resource")

    let revvVaultRef = admin.borrow<&RevvToken.Vault>(from: RevvToken.RevvTokenVaultStoragePath)
      ?? panic("Could not borrow a reference to the REVV vault")

    let revvVault <- revvVaultRef.withdraw(amount: amount)

    adminRef.depositRevv(from: <- (revvVault as! @RevvToken.Vault))
  }
}
