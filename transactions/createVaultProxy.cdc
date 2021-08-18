import REVVVaultAccess from "../contracts/flow/REVVVaultAccess.cdc"

transaction {
    prepare(acct: AuthAccount) {
        let vaultProxy <- REVVVaultAccess.createVaultProxy()
        acct.save(<- vaultProxy, to: REVVVaultAccess.VaultProxyStoragePath)
        acct.link<&REVVVaultAccess.VaultProxy{REVVVaultAccess.VaultProxyPublic}>(REVVVaultAccess.VaultProxyPublicPath, target: REVVVaultAccess.VaultProxyStoragePath)
    }
}