import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"

access(all)
contract REVV: FungibleToken {
  // Max REVV supply
  access(all)
  let MAX_SUPPLY: UFix64
  
  // Total supply of REVV tokens in existence
  access(all)
  var totalSupply: UFix64
  
  // Event that is emitted when the contract is created
  access(all)
  event TokensInitialized(initialSupply: UFix64)
  
  // Event that is emitted when tokens are withdrawn from a Vault
  access(all)
  event TokensWithdrawn(amount: UFix64, from: Address?)
  
  // Event that is emitted when tokens are deposited to a Vault
  access(all)
  event TokensDeposited(amount: UFix64, to: Address?)
  
  // Event that is emitted when new tokens are minted
  access(all)
  event TokensMinted(amount: UFix64)
  
  // The storage path for the Admin token
  access(all)
  let RevvAdminStoragePath: StoragePath
  
  // The public path for the token balance
  access(all)
  let RevvBalancePublicPath: PublicPath
  
  // The public path for the token receiver
  access(all)
  let RevvReceiverPublicPath: PublicPath
  
  // The storage path for the token vault
  access(all)
  let RevvVaultStoragePath: StoragePath
  
  // The private path for the token vault
  access(all)
  let RevvVaultPrivatePath: PrivatePath
  
  // The escrow vault for REVV from REVV vaults that were destroyed
  access(contract)
  let escrowVault: @REVV.Vault

  access(all) view fun getContractViews(resourceType: Type?): [Type] {
      return [
          Type<FungibleTokenMetadataViews.FTView>(),
          Type<FungibleTokenMetadataViews.FTDisplay>(),
          Type<FungibleTokenMetadataViews.FTVaultData>(),
          Type<FungibleTokenMetadataViews.TotalSupply>()
      ]
  }

  access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
      switch viewType {
          case Type<FungibleTokenMetadataViews.FTView>():
              return FungibleTokenMetadataViews.FTView(
                  ftDisplay: self.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTDisplay>()) as! FungibleTokenMetadataViews.FTDisplay?,
                  ftVaultData: self.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
              )
          case Type<FungibleTokenMetadataViews.FTDisplay>():
              let media = MetadataViews.Media(
                      file: MetadataViews.HTTPFile(
                      url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                  ),
                  mediaType: "image/svg+xml"
              )
              let medias = MetadataViews.Medias([media])
              return FungibleTokenMetadataViews.FTDisplay(
                  name: "REVV Token",
                  symbol: "REVV",
                  description: "The native token of @theMotorverse ecosystem, providing utility, medium of exchange and store of value. Seeded by @AnimocaBrands.",
                  externalURL: MetadataViews.ExternalURL("https://motorverse.com/"),
                  logos: medias,
                  socials: {
                      "x": MetadataViews.ExternalURL("https://x.com/REVV_Token")
                  }
              )
          case Type<FungibleTokenMetadataViews.FTVaultData>():
              return FungibleTokenMetadataViews.FTVaultData(
                  storagePath: self.RevvVaultStoragePath,
                  receiverPath: self.RevvReceiverPublicPath,
                  metadataPath: self.RevvReceiverPublicPath,
                  receiverLinkedType: Type<&REVV.Vault>(),
                  metadataLinkedType: Type<&REVV.Vault>(),
                  createEmptyVaultFunction: (fun(): @{FungibleToken.Vault} {
                      return <- REVV.createEmptyVault(vaultType: Type<@REVV.Vault>())
                  })
              )
          case Type<FungibleTokenMetadataViews.TotalSupply>():
              return FungibleTokenMetadataViews.TotalSupply(
                  totalSupply: REVV.totalSupply
              )
      }
      return nil
  }
  
  // Admin resource
  //
  access(all)
  resource Admin {} 
  
  // Vault
  //
  // Each user stores an instance of only the Vault in their storage
  // The functions in the Vault are governed by the pre and post conditions
  // in FungibleToken when they are called.
  // The checks happen at runtime whenever a function is called.
  //
  // Resources can only be created in the context of the contract that they
  // are defined in, so there is no way for a malicious user to create Vaults
  // out of thin air.
  //
  access(all)
  resource Vault: FungibleToken.Vault { 
    
    // holds the balance of a users tokens
    access(all)
    var balance: UFix64
    
    // initialize the balance at resource creation time
    init(balance: UFix64) { 
      self.balance = balance
    }
    
    // withdraw
    //
    // Function that takes an amount as an argument
    // and withdraws that amount from the Vault.
    // It creates a new temporary Vault that is used to hold
    // the money that is being transferred. It returns the newly
    // created Vault to the context that called so it can be deposited
    // elsewhere.
    //
    access(FungibleToken.Withdraw)
    fun withdraw(amount: UFix64): @{FungibleToken.Vault} { 
      self.balance = self.balance - amount
      emit TokensWithdrawn(amount: amount, from: self.owner?.address)
      return <-create Vault(balance: amount)
    }
    
    // deposit
    //
    // Function that takes a Vault object as an argument and adds
    // its balance to the balance of the owners Vault.
    // It is allowed to destroy the sent Vault because the Vault
    // was a temporary holder of the tokens. The Vault's balance has
    // been consumed and therefore the vault can be destroyed.
    //
    access(all)
    fun deposit(from: @{FungibleToken.Vault}): Void { 
      let vault <- from as! @REVV.Vault
      self.balance = self.balance + vault.balance
      emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
      vault.balance = 0.0
      destroy vault
    }
    
    access(all)
    fun createEmptyVault(): @{FungibleToken.Vault} { 
      return <-create Vault(balance: 0.0)
    }

    access(all) view fun getViews(): [Type] {
        return REVV.getContractViews(resourceType: nil)
    }

    access(all) fun resolveView(_ view: Type): AnyStruct? {
        return REVV.resolveContractView(resourceType: nil, viewType: view)
    }

    /// getSupportedVaultTypes optionally returns a list of vault types that this receiver accepts
    access(all) view fun getSupportedVaultTypes(): {Type: Bool} {
        let supportedTypes: {Type: Bool} = {}
        supportedTypes[self.getType()] = true
        return supportedTypes
    }

    access(all) view fun isSupportedVaultType(type: Type): Bool {
        return self.getSupportedVaultTypes()[type] ?? false
    }
    
    access(all)
    view fun isAvailableToWithdraw(amount: UFix64): Bool { 
      return self.balance >= amount
    }

    /// Called when a fungible token is burned via the `Burner.burn()` method
    access(contract) fun burnCallback() {
        if self.balance > 0.0 {
            REVV.depositToEscrow(from: <- create Vault(balance: self.balance))
        }
        self.balance = 0.0
    }
  
  }
  
  // createEmptyVault
  //
  // Function that creates a new Vault with a balance of zero
  // and returns it to the calling context. A user must call this function
  // and store the returned Vault in their storage in order to allow their
  // account to be able to receive deposits of this token type.
  //
  access(all)
  fun createEmptyVault(vaultType: Type): @{FungibleToken.Vault} { 
    return <-create Vault(balance: 0.0)
  }
  
  // depositToEscrow
  //
  // Function accessible from contract only, which deposits REVV into the escrow vault
  //
  access(contract)
  fun depositToEscrow(from: @{FungibleToken.Vault}) { 
    let vault <- from as! @REVV.Vault
    self.escrowVault.deposit(from: <-vault)
  }
  
  // withdraw from escrowVault
  // Public method which requires as argument an admin object reference, which only the account owner has access to
  //
  access(all)
  fun withdrawFromEscrow(adminRef: &Admin, amount: UFix64): @{FungibleToken.Vault} { 
    pre { 
      adminRef != nil:
        "adminRef is nil"
    }
    return <-self.escrowVault.withdraw(amount: amount)
  }
  
  // getEscrowVaultBalance
  //
  // returns the balance for the contract's escrow vault
  //
  access(all)
  fun getEscrowVaultBalance(): UFix64 { 
    return self.escrowVault.balance
  }
  
  // mint 
  // 
  // Can only be called by contract.
  // Total minted amount can never exceed MAX_SUPPLY
  //
  access(contract)
  fun mint(amount: UFix64) { 
    pre { 
      amount > 0.0:
        "Mint amount must be larger than 0.0"
      self.totalSupply + amount <= self.MAX_SUPPLY:
        "totalSupply + mint amount can't exceed max supply"
    }
    let revvVaultRef = self.account.storage.borrow<& {FungibleToken.Vault}>(from: self.RevvVaultStoragePath)!
    let mintVault <- create REVV.Vault(balance: amount)
    revvVaultRef.deposit(from: <-mintVault)
    self.totalSupply = self.totalSupply + amount
    emit TokensMinted(amount: amount)
  }
  
  init() { 
    // Init supply fields
    //
    self.totalSupply = 0.0
    self.MAX_SUPPLY = 3_000_000_000.0
    
    //Initialize the path fields
    //
    self.RevvAdminStoragePath = /storage/revvAdmin
    self.RevvBalancePublicPath = /public/revvBalance
    self.RevvReceiverPublicPath = /public/revvReceiver
    self.RevvVaultStoragePath = /storage/revvVault
    self.RevvVaultPrivatePath = /private/revvVault
    
    // create and store Admin resource 
    // this resource is currently not used by the contract, added in case
    // needed in future
    //
    self.account.storage.save(<-create Admin(), to: self.RevvAdminStoragePath)
    
    // create an escrow vault
    //
    self.escrowVault <- self.createEmptyVault(vaultType: Type<@Vault>()) as! @REVV.Vault
    
    // Create an REVV vault and save it in storage
    //
    let vault <- self.createEmptyVault(vaultType: Type<@Vault>())
    self.account.storage.save(<-vault, to: self.RevvVaultStoragePath)
  

    let tokenCapability: Capability<&REVV.Vault> = self.account.capabilities.storage.issue<&REVV.Vault>(self.RevvVaultStoragePath)
    self.account.capabilities.publish(tokenCapability, at: self.RevvBalancePublicPath)

    var receiverCapability = self.account.capabilities.storage.issue<&REVV.Vault>(self.RevvVaultStoragePath)
    self.account.capabilities.publish(receiverCapability, at: self.RevvReceiverPublicPath)
    
    // Mint total supply
    //
    self.mint(amount: self.MAX_SUPPLY)
    
    // Emit an event that shows that the contract was initialized
    //
    emit TokensInitialized(initialSupply: self.totalSupply)
  }
}