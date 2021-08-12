import REVVVaultAccess from 0xREVVVaultAccess

transaction(vaultProxyOwner: Address) {
    let vaultGuardCap: Capability<&REVVVaultAccess.VaultGuard>
    prepare(acct: AuthAccount) {
        let vaultGuardPaths: REVVVaultAccess.VaultGuardPaths = REVVVaultAccess.getVaultGuardPaths(vaultProxyAddress: vaultProxyOwner)!
        self.vaultGuardCap = acct.getCapability<&REVVVaultAccess.VaultGuard>(vaultGuardPaths.privatePath)
    }
    execute {
        let vaultProxyRef = getAccount(vaultProxyOwner).getCapability<&REVVVaultAccess.VaultProxy{REVVVaultAccess.VaultProxyPublic}>(REVVVaultAccess.VaultProxyPublicPath)!.borrow()!
        vaultProxyRef.setCapability(cap: self.vaultGuardCap)
    }
}