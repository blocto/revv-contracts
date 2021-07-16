import FungibleToken from 0xFUNGIBLETOKENADDRESS
import RevvToken from 0xREVVTOKENADDRESS
import TeleportCustody from 0xREVVTELEPORTCUSTODYADDRESS

transaction(amount: UFix64, target: String) {
  prepare(signer: AuthAccount) {
    let teleportUserRef = getAccount(0xf086a545ce3c552d).getCapability(/public/revvTeleportCustodyTeleportUser)!
        .borrow<&TeleportCustody.TeleportAdmin{TeleportCustody.TeleportUser}>()
        ?? panic("Could not borrow a reference to TeleportUser")

    let vaultRef = signer.borrow<&RevvToken.Vault>(from: RevvToken.RevvTokenVaultStoragePath)
        ?? panic("Could not borrow a reference to the vault resource")

    let vault <- vaultRef.withdraw(amount: amount);
    
    teleportUserRef.teleportOut(from: <- vault, to: target.decodeHex())
  }
}
