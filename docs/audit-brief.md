# 📋 SANCTUARY PROTOCOL — AUDIT PRE-BRIEF

**Document:** `docs/audit-brief.md`  
**Prepared For:** External Security Auditors  
**Date:** 2025-12-25  
**Protocol Version:** v0.2

---

## 1. Executive Summary

**Sanctuary** is a quantum-resilient smart vault protocol that secures digital assets using post-quantum cryptography (CRYSTALS-Dilithium) on Ethereum Layer-2 networks.

The protocol uses an **Attested Verification Pattern** where signatures are validated off-chain by an Attestation Oracle, then verified on-chain through attestation checks.

**Primary Audit Focus:**
- Smart contract logic correctness
- Replay protection mechanisms
- Access control enforcement
- Attestation lifecycle integrity

---

## 2. Codebase Overview

### 2.1 Repository Structure

```
sanctuary/
├── contracts/
│   ├── src/
│   │   └── SanctuaryVault.sol    ← PRIMARY AUDIT TARGET
│   └── test/
│       └── SanctuaryVault.t.sol  ← Test coverage reference
├── client/
│   └── sanctuary-signer/          ← Rust signing library (secondary)
└── docs/
    ├── whitepaper.md
    ├── spec.md                    ← Formal specification
    └── threat-model.md            ← Threat analysis
```

### 2.2 Contract Inventory

| Contract | LoC | Purpose | Audit Priority |
|----------|-----|---------|----------------|
| `SanctuaryVault.sol` | ~340 | Core vault logic | **Critical** |

### 2.3 External Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| Solidity | 0.8.19+ | Smart contract language |
| Foundry | Latest | Build & test framework |
| pqcrypto-dilithium | 0.5.x | Rust PQ crypto (off-chain) |

---

## 3. Architecture Overview

### 3.1 System Flow

```
Owner Device          Attestation Oracle         Vault Contract
     │                        │                        │
     │ 1. Sign(msg, sk)       │                        │
     │───────────────────────▶│                        │
     │                        │ 2. Verify(pk, sig, msg)│
     │                        │───────────────────────▶│
     │                        │ 3. submitAttestation() │
     │                        │───────────────────────▶│
     │                        │                        │ 4. Store attestation
     │ 5. validateUserOp(sig) │                        │
     │────────────────────────────────────────────────▶│
     │                        │                        │ 6. Check attestation
     │                        │                        │ 7. Mark consumed
     │ 8. execute(target)     │                        │
     │────────────────────────────────────────────────▶│
     │                        │                        │ 9. Execute tx
```

### 3.2 Key Design Decisions

1. **Off-Chain Verification:** Dilithium verification happens off-chain due to EVM limitations
2. **Time-Bound Attestations:** 5-minute validity window prevents stale attestations
3. **Single-Use Signatures:** Each signature can only authorize one transaction
4. **Cross-Vault Isolation:** Attestation keys are vault-specific

---

## 4. Threat Model Summary

### 4.1 In-Scope Threats

| Threat | Mitigation |
|--------|------------|
| Signature replay | `consumedSignatures` mapping |
| Stale attestations | `ATTESTATION_VALIDITY` expiry |
| Unauthorized attestation | Oracle-only access control |
| Cross-vault attacks | Vault address in attestation key |

### 4.2 Out-of-Scope Threats

| Threat | Reason |
|--------|--------|
| Owner key compromise | User responsibility |
| L2 sequencer censorship | Availability, not safety |
| Oracle DoS | Availability, not safety |

### 4.3 Trust Assumptions

- **Oracle:** Trusted for availability, not security
- **Owner:** Responsible for key security
- **L2:** Assumed to execute correctly

---

## 5. Key Functions for Review

### 5.1 Critical Functions

| Function | Risk | Focus Areas |
|----------|------|-------------|
| `initialize` | Medium | Double-init, input validation |
| `submitAttestation` | High | Access control, replay prevention |
| `validateUserOp` | Critical | Attestation check, expiry, consumption |
| `execute` | High | Access control, reentrancy |
| `_computeAttestationKey` | Critical | Binding correctness |

### 5.2 State Variables

| Variable | Type | Security Role |
|----------|------|---------------|
| `ownerPkHash` | bytes32 | Identity binding |
| `attestationOracle` | address | Access control |
| `signatureAttestations` | mapping | Attestation timestamps |
| `consumedSignatures` | mapping | Replay protection |
| `nonce` | uint256 | Transaction ordering |

---

## 6. Known Issues & Design Trade-offs

### 6.1 Acknowledged Limitations

1. **Oracle Trust:** The oracle cannot steal funds but can cause availability issues
2. **5-Minute Window:** Fixed expiry may need adjustment for different use cases
3. **No Multi-Sig:** Current version supports single-owner vaults only

### 6.2 Intentional Design Choices

1. **No `execute` Access Control:** Currently simplified for v0.2
2. **Fixed Attestation Expiry:** Hardcoded for simplicity
3. **No Upgradability:** Immutable by design for security

---

## 7. Test Coverage

### 7.1 Test Statistics

```
Suite result: ok. 18 passed; 0 failed
Total gas benchmarks: 2 tests covering attestation + validation costs
```

### 7.2 Invariant Test Mapping

| Invariant | Test(s) |
|-----------|---------|
| I1: No unauthorized execution | `test_RevertWhen_SignatureNotAttested` |
| I2: One signature, one execution | `test_RevertWhen_SignatureReplay` |
| I3: Oracle cannot steal | `test_RevertWhen_NonVerifierAttemptAttestation` |
| I4: Expiry enforcement | `test_RevertWhen_AttestationExpired` |
| I5: Cross-vault isolation | Implicit in `_computeAttestationKey` |

### 7.3 Running Tests

```bash
cd contracts
forge test -vv
```

---

## 8. Audit Scope Definition

### 8.1 In-Scope

- [ ] `SanctuaryVault.sol` - All functions
- [ ] Access control logic
- [ ] Replay protection mechanisms
- [ ] Attestation lifecycle
- [ ] State variable consistency

### 8.2 Out-of-Scope

- [ ] Rust client library (unless requested)
- [ ] Frontend/UI components
- [ ] L2 infrastructure
- [ ] Gas optimization (informational only)

---

## 9. Contact & Resources

### 9.1 Documentation

| Document | Location |
|----------|----------|
| Whitepaper | `docs/whitepaper.md` |
| Formal Spec | `docs/spec.md` |
| Threat Model | `docs/threat-model.md` |
| Security Policy | `SECURITY.md` |

### 9.2 Communication

- **Primary Contact:** [maintainer email]
- **Response Time:** 24-48 hours
- **Preferred Format:** GitHub issues or encrypted email

---

## 10. Appendix: Quick Reference

### 10.1 Constants

```solidity
DILITHIUM2_SIG_SIZE = 2420 bytes
DILITHIUM2_PK_SIZE = 1312 bytes
ATTESTATION_VALIDITY = 5 minutes
```

### 10.2 Error Codes

| Error | Meaning |
|-------|---------|
| `NotInitialized` | Vault not set up |
| `AlreadyInitialized` | Double initialization attempt |
| `InvalidSignatureSize` | Signature != 2420 bytes |
| `InvalidPublicKeySize` | Public key != 1312 bytes |
| `SignatureNotAttested` | No valid attestation found |
| `AttestationExpired` | Attestation older than 5 minutes |
| `SignatureAlreadyUsed` | Replay attempt detected |
| `NotTrustedVerifier` | Caller is not the oracle |
| `InvalidVerifierAddress` | Zero address provided |

---

**End of Audit Pre-Brief**
