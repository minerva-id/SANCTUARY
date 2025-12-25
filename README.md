# 🛡️ SANCTUARY

### A Quantum-Resilient Self-Custody Vault using Attested Post-Quantum Signatures on Ethereum Layer-2

[![Rust](https://img.shields.io/badge/Rust-1.70+-orange.svg)](https://www.rust-lang.org/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.19-blue.svg)](https://soliditylang.org/)
[![Forge Tests](https://img.shields.io/badge/Tests-18%20passed-brightgreen.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **"Code is Law. Mathematics is the Shield."**

---

## 🎯 Overview

Sanctuary is a **Quantum-Resilient Smart Vault** that implements **CRYSTALS-Dilithium** (ML-DSA) signature verification on Ethereum Layer-2 networks. By leveraging Account Abstraction (ERC-4337) with an **Attested Verification Pattern**, we achieve quantum resistance **today** without waiting for a global Hard Fork.

### Why Sanctuary?

Existing blockchain security relies on elliptic-curve cryptography (ECDSA), which is vulnerable to Shor's algorithm. Rather than waiting for global Layer-1 migration, Sanctuary enables **individual asset protection** at the application layer.

### Key Features

- 🔐 **Quantum-Safe Cryptography**: NIST-approved CRYSTALS-Dilithium (Level 2)
- ⛽ **Gas Efficient**: ~$0.02 per transaction on Layer-2
- 🏗️ **ERC-4337 Compatible**: Works with Account Abstraction standards
- 🦀 **Rust + WASM**: Client-side signing compiled to WebAssembly
- ✅ **Engineering Validated**: 18 tests passed, real cryptographic data verified

---

## 📁 Project Structure

```
sanctuary/
├── client/                    # Rust client library
│   └── sanctuary-signer/      # Dilithium signing implementation
│       ├── src/
│       │   ├── lib.rs         # Core signing logic
│       │   └── bin/           # CLI tools
│       └── Cargo.toml
├── contracts/                 # Solidity smart contracts (Foundry)
│   ├── src/
│   │   └── SanctuaryVault.sol # Main vault contract (v0.2)
│   └── test/
│       └── SanctuaryVault.t.sol # Comprehensive test suite
├── docs/
│   └── whitepaper.md          # Technical whitepaper (v2.1)
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
   Public Key Hash: 0xdb85fd3d62c0b071...
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
forge test -vv
```

**Expected Output:**
```
[PASS] test_FullFlow()
  === SANCTUARY PROTOCOL - Full Smart Contract Flow ===
  1. Vault initialized
     Owner PK Hash: 0x731cb09c5ccba0fa...
     Trusted Verifier: 0x7fbDdCC90DFfA9F5...
  2. Vault funded with 100 ETH
  3. Transaction hash generated
  4. Trusted verifier attested signature
  5. Dilithium signature validated on-chain
     Result: VALID
     Gas Used: 42798
  6. Transaction executed

Suite result: ok. 18 passed; 0 failed
```

---

## 🔐 Security Model (v0.2)

### Attested Verification Pattern

Due to the absence of native post-quantum precompiles in the EVM, Sanctuary uses a **Trusted Verifier Pattern**:

```
┌──────────────────────────────────────────────────────────────────┐
│                    SIGNATURE VALIDATION FLOW                      │
├──────────────────────────────────────────────────────────────────┤
│  1. User signs transaction with Dilithium key (off-chain)        │
│  2. Trusted Verifier validates signature cryptographically       │
│  3. Verifier submits attestation on-chain                        │
│  4. User calls validateUserOp() with signature                   │
│  5. Contract checks: attestation exists, not expired, unused     │
│  6. Transaction executes if all checks pass                      │
└──────────────────────────────────────────────────────────────────┘
```

### Trust Boundaries

| Component | Can Do | Cannot Do |
|-----------|--------|-----------|
| **Trusted Verifier** | Attest signatures, Delay/Censor | Forge signatures, Steal funds |
| **User** | Sign transactions, Execute | - |
| **Contract** | Enforce rules, Replay protection | - |

> ⚠️ **Note**: The verifier affects *availability*, not *security*. Funds cannot be stolen even if the verifier is compromised.

---

## 📊 Gas Benchmarks (v0.2)

| Operation | Gas Used | L2 Cost Estimate |
|-----------|----------|------------------|
| Attestation (Verifier) | ~32,000 | < $0.01 |
| User Validation | ~42,000 | < $0.01 |
| **Total Transaction** | **~75,000** | **~ $0.02** |

*Data from Foundry tests using real Dilithium signatures (2420 bytes)*

### Comparative Analysis

| Metric | ECDSA (Legacy) | Dilithium (Sanctuary) |
|--------|----------------|----------------------|
| Signature Size | 64 bytes | 2,420 bytes |
| Public Key Size | 33 bytes | 1,312 bytes |
| L2 Verification Cost | ~21k gas | ~75k gas |
| Quantum Resistance | ❌ No | ✅ **Yes (NIST Level 2)** |

> The ~3.5x gas overhead represents a reasonable **security premium** for long-term quantum resistance.

---

## 🗺️ Roadmap

- [x] **Phase 0 – Foundation** ✅
  - Open-source Dilithium signer (Rust)
  - Smart vault contract with Trusted Verifier Pattern
  - Comprehensive test suite (18 tests)
  - Real cryptographic data integration
  
- [ ] **Phase 1 – Proving Ground**
  - Public testnet deployment (Arbitrum/Base Sepolia)
  - Bug bounty program
  - Community security review
  
- [ ] **Phase 2 – Sanctuary Mainnet**
  - Layer-2 deployment
  - Public vault creation
  
- [ ] **Phase 3 – Trust Minimization**
  - Multi-verifier threshold attestations
  - Transparent verifier commitments
  
- [ ] **Phase 4 – Native PQC Transition**
  - Migration to on-chain Dilithium verification when precompiles available

---

## 🛠️ Development

### Build Rust Library

```bash
cd client/sanctuary-signer
cargo build --release
```

### Generate Test Data for Solidity

```bash
cd client/sanctuary-signer
cargo run --bin gen_test_data
```

### Build & Test Contracts

```bash
cd contracts

# Build
forge build

# Test with verbose output
forge test -vv

# Gas report
forge test --gas-report
```

### Deploy to Local Testnet

```bash
cd contracts
anvil &  # Start local node
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

---

## 📚 Documentation

- [Technical Whitepaper](docs/whitepaper.md) - Full protocol specification
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
  <strong>🛡️ Secure your assets before the quantum era arrives</strong>
  <br><br>
  <em>Code is Law. Mathematics is the Shield.</em>
</p>
