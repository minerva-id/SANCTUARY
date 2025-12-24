# 🛡️ SANCTUARY

### A Quantum-Resistant Self-Custody Protocol using Lattice-Based Cryptography on Ethereum Layer-2

[![Rust](https://img.shields.io/badge/Rust-1.70+-orange.svg)](https://www.rust-lang.org/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.19-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **"Code is Law. Mathematics is the Shield"**

---

## 🎯 Overview

Sanctuary is a decentralized Smart Vault protocol that implements **CRYSTALS-Dilithium** (ML-DSA) signature verification on Ethereum Layer-2 networks. By leveraging Account Abstraction (ERC-4337), we achieve quantum resistance today without waiting for a global Hard Fork.

### Key Features

- 🔐 **Quantum-Safe Cryptography**: Uses NIST-approved CRYSTALS-Dilithium (Level 2)
- ⛽ **Gas Efficient**: Deployed on L2 for <$0.10 transaction costs
- 🏗️ **ERC-4337 Compatible**: Works with Account Abstraction standards
- 🦀 **Rust + WASM**: Client-side signing compiled to WebAssembly

---

## 📁 Project Structure

```
sanctuary/
├── client/                    # Rust client library
│   └── sanctuary-signer/      # Dilithium signing implementation
│       ├── src/lib.rs         # Core signing logic
│       └── Cargo.toml         # Dependencies
├── contracts/                 # Solidity smart contracts
│   ├── src/
│   │   └── SanctuaryVault.sol # Main vault contract
│   └── test/
│       └── SanctuaryVault.t.sol # Foundry tests
├── docs/                      # Documentation
│   └── whitepaper.md          # Technical whitepaper
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites

- **Rust** (1.70+): https://rustup.rs/
- **Foundry**: https://getfoundry.sh/

### 1. Clone & Setup

```bash
git clone https://github.com/your-username/sanctuary.git
cd sanctuary
```

### 2. Run Rust Tests (Client-Side Signer)

```bash
cd client/sanctuary-signer
cargo test -- --nocapture
```

**Expected Output:**
```
=== SANCTUARY PROTOCOL - Full Transaction Flow ===

1. Wallet Created
   Public Key Hash: 0x...
2. Transaction Created
   To: 0x742d35Cc6634C0532925a3b844Bc9e7595f8b2E1
   Value: 1000000000000000000 wei
3. Transaction Signed
   Signature Size: 2420 bytes    ← Dilithium Level 2
4. Signature Verified: true

=== Transaction Ready for L2 Submission ===

test result: ok. 5 passed; 0 failed
```

### 3. Run Smart Contract Tests

```bash
cd contracts
forge test -vvv
```

**Expected Output:**
```
[PASS] test_FullFlow() 
  === SANCTUARY PROTOCOL - Full Smart Contract Flow ===
  1. Vault initialized
  2. Vault funded with 100 ETH
  3. Transaction hash generated
  4. Dilithium signature validated
     Gas Used: ~175,000
  5. Transaction executed

Suite result: ok. 9 passed; 0 failed
```

---

## 📊 Gas Benchmarks

| Operation | Gas Used | Est. L1 Cost (30 gwei) | Est. L2 Cost |
|-----------|----------|------------------------|--------------|
| Initialize Vault | ~1,097,470 | $33 | **<$0.10** |
| Validate Signature | ~175,494 | $5.26 | **<$0.02** |
| Execute Transaction | ~50,000 | $1.50 | **<$0.01** |

*L2 costs are estimates for Arbitrum/Base at typical conditions*

---

## 🔒 Security Considerations

### Cryptographic Security

| Metric | ECDSA (Legacy) | Dilithium (Sanctuary) |
|--------|---------------|----------------------|
| Quantum Resistance | ❌ No | ✅ **Yes** |
| Implementation Risk | Low | **Low (Integer Math)** |
| Signature Size | 64 bytes | **2,420 bytes** |
| NIST Security Level | - | **Level 2** |

### Current Limitations (v0.1)

⚠️ **This is a Proof-of-Concept**: The Dilithium signature verification in `SanctuaryVault.sol` is currently a **stub**. Full mathematical verification is planned for v0.2.

Options being evaluated:
1. EVM precompile (requires L2 support)
2. Pure Solidity/Yul implementation
3. ZK-SNARK proof of valid signature

---

## 🗺️ Roadmap

- [x] **Phase 0 (Genesis)**: Open-source libraries for Dilithium signing ✅
- [ ] **Phase 1 (Proving Ground)**: Deployment on Arbitrum Sepolia Testnet
- [ ] **Phase 2 (The Sanctuary)**: Mainnet deployment

---

## 🛠️ Development

### Build Rust Library

```bash
cd client/sanctuary-signer
cargo build --release
```

### Build & Deploy Contracts

```bash
cd contracts

# Build
forge build

# Deploy to local testnet
anvil &  # Start local node
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Run All Tests

```bash
# From project root
cd client/sanctuary-signer && cargo test
cd ../../contracts && forge test
```

---

## 📚 Documentation

- [Technical Whitepaper](docs/whitepaper.md)
- [API Reference](docs/api.md) *(coming soon)*
- [Security Audit](docs/audit.md) *(coming soon)*

---

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/quantum-magic`)
3. Commit your changes (`git commit -m 'Add quantum magic'`)
4. Push to the branch (`git push origin feature/quantum-magic`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚡ Acknowledgments

- [NIST Post-Quantum Cryptography Project](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [pqcrypto-dilithium](https://crates.io/crates/pqcrypto-dilithium) Rust library
- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit
- [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) - Account Abstraction

---

<p align="center">
  <strong>🛡️ Protect your assets before the quantum era arrives</strong>
</p>
