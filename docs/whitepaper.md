# **SANCTUARY**

### **A Quantum-Resistant Self-Custody Protocol using Lattice-Based Cryptography on Ethereum Layer-2**

Abstract  
Shor’s algorithm presents an existential threat to the Elliptic Curve Digital Signature Algorithm (ECDSA) schemes that currently secure trillions of dollars in crypto-assets. While Layer-1 protocol upgrades face significant political and technical inertia, the necessity for asset protection is immediate. This paper proposes Sanctuary: a decentralized Smart Vault protocol leveraging Account Abstraction (ERC-4337) standards to implement CRYSTALS-Dilithium signature verification on Ethereum Layer-2 networks. By decoupling cryptographic logic from the consensus protocol and moving it to the smart contract level, we achieve quantum resistance today without awaiting a global Hard Fork, while maintaining gas efficiency through Layer-2 data compression.

## ---

**1\. Introduction**

The security of Bitcoin, Ethereum, and the majority of modern blockchain infrastructure relies on the discrete logarithm problem over elliptic curves (*secp256k1* or *Ed25519*). A sufficiently powerful quantum computer could theoretically solve this problem in polynomial time, allowing an adversary to derive a Private Key from an exposed Public Key.

Although Post-Quantum Cryptography (PQC) standards were finalized by NIST (2024), Layer-1 adoption is hindered by two primary factors:

1. **Data Size:** PQC signatures (e.g., Dilithium) are approximately \~2.4 KB in size, orders of magnitude larger than ECDSA (64 bytes), posing a massive burden on blockchain state.  
2. **Consensus Inertia:** Replacing the underlying signature scheme requires global coordination, which is slow and carries the risk of contentious chain splits.

We propose a pragmatic approach: **Risk Isolation**. Rather than modifying the entire chain, we create a "Secure Enclave" (*Sanctuary*) within existing chains using programmable verification logic.

## 

## 

## 

## **2\. Technical Architecture**

Sanctuary is not a new Layer-1 blockchain. It is an application-layer protocol running atop Optimistic Rollups (such as Arbitrum or Base). The system comprises three core components:

### **2.1. The Lattice Signer (Client-Side)**

User interaction no longer relies on standard wallets (Metamask/Phantom). We introduce a *Lightweight Rust Client* compiled to WebAssembly (WASM).

* **Algorithm:** CRYSTALS-Dilithium (ML-DSA). Selected for its deterministic nature and resistance to Side-Channel Attacks, unlike FALCON which utilizes Floating Point Arithmetic—a risk in heterogeneous environments.  
* **Key Generation:** Private keys are generated locally on the user's device and never leave the client side.

### **2.2. The Smart Vault (On-Chain Logic)**

We leverage the **ERC-4337 (Account Abstraction)** standard to decouple asset ownership from validation logic.

* **Custom Validation:** The SanctuaryVault.sol contract bypasses Ethereum's standard ecrecover mechanism (ECDSA).  
* **Verify Function:** This contract contains an EVM-optimized Dilithium verifier implementation. Transactions are executed only if the input data contains a valid \~2.4 KB Dilithium signature corresponding to the Vault owner's Public Key.

### **2.3. Cost Efficiency via Layer-2**

The primary challenge of PQC is gas cost. Verifying a 2.4 KB signature on Ethereum Mainnet (L1) incurs prohibitive costs (\~$50-$100).  
Sanctuary mitigates this by deploying on Layer-2:

* On L2, *Call Data* costs (signature storage) are significantly lower than computation costs.  
* The estimated transaction cost for Sanctuary is \<$0.10, making it viable for both retail and institutional use while retaining absolute *Theft-Resistance* guarantees.

## 

## 

## 

## 

## **3\. Security & Gas Analysis**

Referring to recent discourse regarding "Gas per Security-Bit" metrics (EthResearch, 2025), Sanctuary adopts a "Security-Maximalist" position.

| Metric | ECDSA (Legacy) | FALCON (PQC) | Dilithium (Sanctuary) |
| :---- | :---- | :---- | :---- |
| **Quantum Resistance** | No | Yes | **Yes** |
| **Implementation Risk** | Low | High (FPU/Side-channel) | **Low (Integer Math)** |
| **Signature Size** | 64 Bytes | \~666 Bytes | **\~2.4 KB** |
| **Physical Security** | Compromised | Medium | **High (NIST Level 3\)** |

Although Dilithium is more byte-intensive, we argue that the additional gas cost acts as a reasonable insurance premium for long-term asset security. In the context of L2, this cost differential is negligible compared to the risk of total fund loss.

## 

## 

## 

## 

## 

## 

## 

## 

## **4\. Threat Model**

### **4.1. Sequencer Censorship**

Sanctuary operates on L2s where the Sequencer may not yet be Quantum-Safe.

* **Scenario:** A quantum adversary compromises the L2 Sequencer.  
* **Impact:** The adversary may censor transactions (refusing to process Sanctuary txs) or halt the network (*Liveness Failure*).  
* **Mitigation:** The adversary **CANNOT** forge a user's Dilithium signature. Funds within the Vault remain secure (*Safety Preserved*). Assets may be temporarily frozen, but they cannot be stolen.

### **4.2. Implementation Bugs**

The greatest risk in new cryptographic systems is code error.

* **Mitigation:** The Dilithium verifier code is written in pure Rust, extensively tested against NIST test vectors, and compiled into bytecode that minimizes logic complexity. The project's Open Source nature allows for continuous public auditing.

## **5\. Roadmap to Sovereignty**

1. **Phase 0 (Genesis):** Release of open-source libraries for Dilithium signing (Rust/WASM) and EVM verification contracts.  
2. **Phase 1 (Proving Ground):** Deployment on Public Testnet (Arbitrum Sepolia). Open Bounty for anyone able to breach the Vault.  
3. **Phase 2 (The Sanctuary):** Mainnet Deployment. Opening access for the public to migrate assets from vulnerable EOA wallets to secure Sanctuary Vaults.

## **6\. Conclusion**

We need not await global consensus to secure individual assets. By combining the flexibility of Account Abstraction with the robustness of Lattice-Based Cryptography, Sanctuary provides a practical and immediate solution to an inevitable problem. It is not about predicting when the quantum computer arrives, but about infrastructure readiness when that day comes.

**Code is Law. Mathematics is the Shield**