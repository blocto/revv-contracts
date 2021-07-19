# REVV Teleport Contracts
Cadence and Solidity contracts used in REVV Teleport

Flow Playground: https://play.onflow.org/8afc7ece-5e1c-4be1-a80d-1fdaa955c133?type=account&id=0

## Deployment
Deploy the updated contracts to Flow testnet with Flow CLI.
The accounts to deploy to are defined in `flow.json`
```sh
flow project deploy --network testnet --update
```

## Operation
### Setup Teleport Admin
```
# Create build folder
mkdir build

# Build the trasnaction
flow transactions build ./transactions/setupTeleportAdmin.cdc \
  --network testnet \
  --arg UFix64:1000000000.0 \
  --proposer 0xd26e915a5ca720cd \
  --proposer-key-index 0 \
  --authorizer 0xd26e915a5ca720cd \
  --authorizer 0x205d4db4d4592a73 \
  --payer 0x205d4db4d4592a73 \
  --gas-limit 1000 \
  -x payload \
  --save ./build/unsigned.rlp

# Sign with REVV Admin account
flow transactions sign ./build/unsigned.rlp \
  --signer revv-admin-testnet \
  --filter payload \
  --save ./build/signed-1.rlp

# Sign with REVV Teleport Admin account
flow transactions sign ./build/signed-1.rlp \
  --signer revv-teleport-admin-testnet \
  --filter payload \
  --save ./build/signed-2.rlp

# Send signed transaction
flow transactions send-signed --network testnet ./build/signed-2.rlp
```
