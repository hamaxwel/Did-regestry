# DID Registry

A world-class, modular, and upgradeable Decentralized Identifier (DID) Registry smart contract system with full meta-transaction (EIP-2771) support. Built with Solidity, Hardhat, OpenZeppelin, and Ethers.js.

## 🚀 Features
- **Modular, upgradeable architecture** (UUPS proxy pattern)
- **Meta-transaction support** (EIP-2771, gasless user experience)
- **Admin role & emergency controls** (pause/unpause, force-revoke)
- **Ownership transfer** for DIDs
- **DID metadata history** (audit trail)
- **Rich events** for all actions
- **Secure access control** (OpenZeppelin roles)
- **Ready for off-chain and frontend integration**

## 🏗️ Architecture
- `DIDRegistry.sol` — Main contract, inherits all logic and OpenZeppelin upgradeable contracts
- `DIDRegistryStorage.sol` — Storage structs and mappings
- `DIDRegistryEvents.sol` — Events
- `DIDRegistryAdmin.sol` — Admin/emergency logic
- `DIDRegistryMetaTx.sol` — Meta-transaction logic (EIP-2771)
- `Forwarder.sol` — Minimal EIP-2771 trusted forwarder
- `scripts/` — Deployment and meta-transaction scripts

## ⚡ Quick Start

### 1. Install dependencies
```bash
npm install
```

### 2. Start a local Hardhat node
```bash
npx hardhat node
```

### 3. Deploy contracts
```bash
npx hardhat run scripts/deploy.js --network localhost
```
Copy the printed Forwarder and DIDRegistry addresses.

### 4. Register a DID via meta-transaction
```bash
FORWARDER_ADDRESS=<forwarder_address> REGISTRY_ADDRESS=<registry_address> npx hardhat run scripts/metaRegisterDID.js --network localhost
```

## 🧩 Meta-Transaction Flow
- User signs a meta-transaction for `registerDID`.
- Relayer submits it to the `Forwarder` contract.
- `Forwarder` executes the call on the DIDRegistry, paying gas.
- DID is registered on-chain, and events are emitted.

## 🛠️ Project Structure
```
contracts/
  DIDRegistry.sol
  DIDRegistryStorage.sol
  DIDRegistryEvents.sol
  DIDRegistryAdmin.sol
  DIDRegistryMetaTx.sol
  Forwarder.sol
scripts/
  deploy.js
  metaRegisterDID.js
hardhat.config.js
package.json
.gitignore
README.md
```

## 📝 Contribution
- Fork the repo and create a feature branch.
- Follow Solidity and JS best practices.
- Run tests and lint before submitting a PR.
- Open an issue for feature requests or bugs.

## 📄 License
MIT

---

**Built with ❤️ by world-class Solidity and web3 engineers.** 