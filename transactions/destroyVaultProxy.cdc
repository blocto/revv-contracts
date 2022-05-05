import REVVVaultAccess from "../contracts/flow/REVVVaultAccess.cdc"

transaction {
    prepare(acct: AuthAccount) {
        acct.unlink(REVVVaultAccess.VaultProxyPublicPath)
        let vaultProxy <- acct.load<@AnyResource>(from: REVVVaultAccess.VaultProxyStoragePath)  
        destroy vaultProxy
    }
}