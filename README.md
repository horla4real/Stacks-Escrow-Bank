# Stacks Escrow Bank

A decentralized escrow service built on the Stacks blockchain using Clarity smart contracts. This platform enables secure peer-to-peer transactions by holding funds in escrow until both parties fulfill their obligations.

## Features

- **Secure Escrow**: Funds are held securely in smart contracts
- **Buyer Protection**: Buyers can cancel transactions if terms aren't met
- **Transparent**: All transactions are publicly verifiable on the blockchain
- **Low Fees**: Minimal transaction costs using STX

## Smart Contract Functions

### Public Functions
- `create-escrow(seller, amount)` - Create new escrow transaction
- `release-escrow(escrow-id)` - Release funds to seller (buyer only)
- `cancel-escrow(escrow-id)` - Cancel and refund escrow (buyer/seller)

### Read-Only Functions
- `get-escrow(escrow-id)` - Get escrow details
- `get-total-escrows()` - Get total number of escrows created

## Installation & Testing

```bash
git clone <repository>
cd stacks-escrow-bank
clarinet check
clarinet test