import "TeleportCustody"

transaction {
  prepare(admin: auth(LoadValue) &Account) {
    destroy <- admin.storage.load<@AnyResource>(from: TeleportCustody.AdminStoragePath)
  }
}
