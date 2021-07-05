import FungibleToken from 0xFUNGIBLETOKENADDRESS
import RevvToken from 0xREVVTOKENADDRESS

pub contract TeleportCustody {
  // Frozen flag controlled by Admin
  pub var isFrozen: Bool

  // Record teleported Ethereum hashes
  pub var teleported: {String: Bool}

  // Controls RevvToken vault
  access(contract) let revvVault: @RevvToken.Vault

  // Event that is emitted when new tokens are teleported in from Ethereum (from: Ethereum Address, 20 bytes)
  pub event TokensTeleportedIn(amount: UFix64, from: [UInt8], hash: String)

  // Event that is emitted when tokens are destroyed and teleported to Ethereum (to: Ethereum Address, 20 bytes)
  pub event TokensTeleportedOut(amount: UFix64, to: [UInt8])

  // Event that is emitted when teleport fee is collected (type 0: out, 1: in)
  pub event FeeCollected(amount: UFix64, type: UInt8)

  // Event that is emitted when a new burner resource is created
  pub event TeleportAdminCreated(allowedAmount: UFix64)

  pub resource Allowance {
    pub var balance: UFix64

    // initialize the balance at resource creation time
    init(balance: UFix64) {
      self.balance = balance
    }
  }

  pub resource Administrator {

    // createNewTeleportAdmin
    //
    // Function that creates and returns a new teleport admin resource
    //
    pub fun createNewTeleportAdmin(allowedAmount: UFix64): @TeleportAdmin {
      emit TeleportAdminCreated(allowedAmount: allowedAmount)
      return <- create TeleportAdmin(allowedAmount: allowedAmount)
    }

    pub fun freeze() {
      TeleportCustody.isFrozen = true
    }

    pub fun unfreeze() {
      TeleportCustody.isFrozen = false
    }

    pub fun createAllowance(allowedAmount: UFix64): @Allowance {
      return <- create Allowance(balance: allowedAmount)
    }
  }

  pub resource interface TeleportUser {
    // fee collected when token is teleported from Ethereum to Flow
    pub var inwardFee: UFix64

    // fee collected when token is teleported from Flow to Ethereum
    pub var outwardFee: UFix64
    
    // the amount of tokens that the admin is allowed to teleport
    pub var allowedAmount: UFix64

    // corresponding controller account on Ethereum
    pub var ethereumAdminAccount: [UInt8]

    pub fun teleportOut(from: @RevvToken.Vault, to: [UInt8])

    pub fun depositAllowance(from: @Allowance)
  }

  pub resource interface TeleportControl {
    pub fun teleportIn(amount: UFix64, from: [UInt8], hash: String): @FungibleToken.Vault

    pub fun withdrawFee(amount: UFix64): @FungibleToken.Vault
    
    pub fun updateInwardFee(fee: UFix64)

    pub fun updateOutwardFee(fee: UFix64)

    pub fun updateEthereumAdminAccount(account: [UInt8])
  }

  // TeleportAdmin resource
  //
  //  Resource object that has the capability to teleport tokens
  //  upon receiving teleport request from Ethereum side
  //
  pub resource TeleportAdmin: TeleportUser, TeleportControl {
    
    // the amount of tokens that the admin is allowed to teleport
    pub var allowedAmount: UFix64

    // receiver reference to collect teleport fee
    pub let feeCollector: @RevvToken.Vault

    // fee collected when token is teleported from Ethereum to Flow
    pub var inwardFee: UFix64

    // fee collected when token is teleported from Flow to Ethereum
    pub var outwardFee: UFix64

    // corresponding controller account on Ethereum
    pub var ethereumAdminAccount: [UInt8]

    // deposit
    // 
    // Function that deposits REVV token into the contract controlled
    // vault.
    //
    pub fun deposit(from: @RevvToken.Vault) {
      TeleportCustody.revvVault.deposit(from: <- from)
    }

    // teleportIn
    //
    // Function that release REVV tokens from custody,
    // and returns them to the calling context.
    //
    pub fun teleportIn(amount: UFix64, from: [UInt8], hash: String): @FungibleToken.Vault {
      pre {
        !TeleportCustody.isFrozen: "Teleport service is frozen"
        amount <= self.allowedAmount: "Amount teleported must be less than the allowed amount"
        amount > self.inwardFee: "Amount teleported must be greater than inward teleport fee"
        from.length == 20: "Ethereum address should be 20 bytes"
        hash.length == 64: "Ethereum tx hash should be 32 bytes"
        !(TeleportCustody.teleported[hash] ?? false): "Same hash already teleported"
      }
      self.allowedAmount = self.allowedAmount - amount

      TeleportCustody.teleported[hash] = true
      emit TokensTeleportedIn(amount: amount, from: from, hash: hash)

      let vault <- TeleportCustody.revvVault.withdraw(amount: amount)
      let fee <- vault.withdraw(amount: self.inwardFee)

      self.feeCollector.deposit(from: <-fee)
      emit FeeCollected(amount: self.inwardFee, type: 1)

      return <- vault
    }

    // teleportOut
    //
    // Function that destroys a Vault instance, effectively burning the tokens.
    //
    // Note: the burned tokens are automatically subtracted from the 
    // total supply in the Vault destructor.
    //
    pub fun teleportOut(from: @RevvToken.Vault, to: [UInt8]) {
      pre {
        !TeleportCustody.isFrozen: "Teleport service is frozen"
        to.length == 20: "Ethereum address should be 20 bytes"
      }

      let vault <- from as! @RevvToken.Vault
      let fee <- vault.withdraw(amount: self.outwardFee)

      self.feeCollector.deposit(from: <-fee)
      emit FeeCollected(amount: self.outwardFee, type: 0)

      let amount = vault.balance
      TeleportCustody.revvVault.deposit(from: <- vault)
      emit TokensTeleportedOut(amount: amount, to: to)
    }

    pub fun withdrawFee(amount: UFix64): @FungibleToken.Vault {
      return <- self.feeCollector.withdraw(amount: amount)
    }

    pub fun updateInwardFee(fee: UFix64) {
      self.inwardFee = fee
    }

    pub fun updateOutwardFee(fee: UFix64) {
      self.outwardFee = fee
    }

    pub fun updateEthereumAdminAccount(account: [UInt8]) {
      pre {
        account.length == 20: "Ethereum address should be 20 bytes"
      }

      self.ethereumAdminAccount = account
    }

    pub fun getFeeAmount(): UFix64 {
      return self.feeCollector.balance
    }

    pub fun depositAllowance(from: @Allowance) {
      self.allowedAmount = self.allowedAmount + from.balance

      destroy from
    }

    init(allowedAmount: UFix64) {
      self.allowedAmount = allowedAmount

      self.feeCollector <- RevvToken.createEmptyVault() as! @RevvToken.Vault
      self.inwardFee = 0.01
      self.outwardFee = 10.0

      self.ethereumAdminAccount = []
    }

    destroy() {
      destroy self.feeCollector
    }
  }

  init() {
    self.isFrozen = false
    self.teleported = {}

    // Setup internal RevvToken vault
    self.revvVault <- RevvToken.createEmptyVault() as! @RevvToken.Vault

    let admin <- create Administrator()
    self.account.save(<-admin, to: /storage/revvTeleportCustodyAdmin)
  }
}