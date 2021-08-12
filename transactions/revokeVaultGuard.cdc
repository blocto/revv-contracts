import REVVVaultAccess from 0xREVVVaultAccess

transaction(vaultProxyAddress: Address) {
    var adminRef: &REVVVaultAccess.Admin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&REVVVaultAccess.Admin>(from: REVVVaultAccess.AdminStoragePath)!
    }
    execute {
        REVVVaultAccess.revokeVaultGuard(adminRef: self.adminRef, vaultProxyAddress: vaultProxyAddress)
    }
}