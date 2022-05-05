import REVV from "../contracts/flow/REVV.cdc"
import REVVVaultAccess from "../contracts/flow/REVVVaultAccess.cdc"
import TeleportCustody from "../contracts/flow/TeleportCustody.cdc"

transaction(teleportAdminAddress: Address, amount: UFix64) {
  let vaultProxyRef: &REVVVaultAccess.VaultProxy
  let ownedRevvVaultRef: &REVV.Vault 
  let adminRef: &TeleportCustody.Administrator

  prepare(acct: AuthAccount) {
    self.vaultProxyRef = acct.borrow<&REVVVaultAccess.VaultProxy>(from: REVVVaultAccess.VaultProxyStoragePath)!
    self.ownedRevvVaultRef = acct.borrow<&REVV.Vault>(from: REVV.RevvVaultStoragePath)!
    self.adminRef = acct.borrow<&TeleportCustody.Administrator>(from: TeleportCustody.AdminStoragePath)
      ?? panic("Could not borrow a reference to the admin resource")
  }

  execute {
    // Add allowance to teleport admin
    let allowance <- self.adminRef.createAllowance(allowedAmount: amount)

    let teleportUserRef = getAccount(teleportAdminAddress).getCapability(TeleportCustody.TeleportUserPublicPath)!
      .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>()
      ?? panic("Could not borrow a reference to TeleportUser")

    teleportUserRef.depositAllowance(from: <- allowance)

    // Withdraw from VaultProxy and deposit into contract
    let revvVault <- self.vaultProxyRef.withdraw(amount: amount)
    self.adminRef.depositRevv(from: <- (revvVault as! @REVV.Vault))
  }
}
