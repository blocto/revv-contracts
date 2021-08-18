transaction {
  prepare(admin: AuthAccount) {
    destroy <- admin.load<@AnyResource>(from: /storage/revvTeleportCustodyAdmin)
  }
}
