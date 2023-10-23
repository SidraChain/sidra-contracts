# Genesis Smart Contracts for Sidra Chain

These are the genesis smart contracts designed specifically for the Sidra Chain.

### Libraries

#### 1. **Pausable.sol**

This library provides mechanisms to pause and unpause certain functionalities of a contract. It's essential for emergency situations or maintenance periods.

- **Features**:
    - **Pause and Unpause**: Provides functions to pause and unpause the contract.
    - **Modifiers**: Includes modifiers to easily check the pause status or ownership before executing functions.
    - **Events**: Emits events when the contract is paused or unpaused.

### Core Contracts

### 1. **Owner.sol**

This contract establishes a foundational ownership model for the Sidra Chain.

- **Features**:
    - **Ownership**: Only the owner of the contract can execute specific privileged functions.
    - **Transfer Ownership**: The current owner has the capability to transfer ownership to another Ethereum address.
    - **Check Ownership**: Any user can verify if a particular address is the current owner.

### 2. **WalletAccessControl.sol**

This contract manages the access control for wallets on the Sidra Chain, offering the ability to enable or disable specific Ethereum addresses. It builds upon the ownership model instantiated by the `Owner` contract.

- **Features**:
    - **Access Control**: Individual wallets can be either enabled or disabled.
    - **Batch Operations**: Provides the ability to enable or disable a batch of wallets in a single transaction.
    - **Wallet Verification**: Check if a specific wallet is enabled or disabled.

### 3. **SidraToken.sol**

This contract introduces the Sidra Token (ST) on the Sidra Chain. While it shares similarities with the ERC-20 token standard, it is not an ERC-20 token. The Sidra Token incorporates unique features such as a mining mechanism, conversion to coins, and miner management. Additionally, it offers functionalities to pause and unpause its operations.

- **Features**:
    - **Token Properties**: Defining attributes such as token symbol, name, decimals, total supply, and circulating supply.
    - **Mining**: Designated miners can mine the token and in return receive rewards.
    - **Conversion**: Sidra Tokens can be converted into coins (conversion is managed at the consensus layer).
    - **Miner Management**: The owner can add or remove miners.
    - **Minting**: Mint new tokens by the owner.
    - **Pausing Mechanism**: The contract can be paused or unpaused based on requirements.

### 4. **MainFaucet.sol**

This contract operates as a faucet to distribute coins to specific wallets on the Sidra Chain. It builds upon the ownership model instantiated by the `Owner` contract.

- **Features**:
    - **Coin Distribution**: Enabled by a function that transfers coins from the contract to a specified recipient.
    - **Balance Tracking**: Keeps track of the amount of coins sent to each wallet and the number of coins received by the contract.
    - **Balance Retrieval**: Provides a function to check the contract's balance.
    - **Event Logging**: Logs events for sent and received transactions with details on the involved wallet, amount, and timestamp.

### 5. **Waqf.sol**

This contract handles the receipt of waqf (charitable donations) and ensures they are properly burned to eliminate them from the circulating supply.

- **Features**:
    - **Waqf Receipt**: Utilizes a fallback function to receive coins into the contract.
    - **Balance Tracking**: Keeps track of the total waqf received and the amount received from each donor.
    - **Coin Burning**: Transfers received coins to the zero address to burn them.
    - **Event Logging**: Logs an event for each receipt of waqf with details on the donating wallet, amount, and timestamp.

## Notes

- As these are genesis contracts for the Sidra Chain, they are designed for direct initialization in the genesis block.
