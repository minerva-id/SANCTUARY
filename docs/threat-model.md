# 🛡️ SANCTUARY THREAT MODEL

**One-Page Security Overview for Rapid Review**

---

## System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SANCTUARY PROTOCOL                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────────┐         ┌──────────────────┐         ┌────────────────┐  │
│   │              │         │                  │         │                │  │
│   │    OWNER     │────────▶│  ATTESTATION     │────────▶│     VAULT      │  │
│   │              │  sign   │     ORACLE       │  attest │   (on-chain)   │  │
│   │  (off-chain) │         │   (off-chain)    │         │                │  │
│   └──────────────┘         └──────────────────┘         └───────┬────────┘  │
│          │                          │                           │           │
│          │ Dilithium               │ Verify                    │ Execute   │
│          │ Private Key              │ Signature                 │ Tx        │
│          ▼                          ▼                           ▼           │
│   ┌──────────────┐         ┌──────────────────┐         ┌────────────────┐  │
│   │  SIGNATURE   │         │   ATTESTATION    │         │    TARGET      │  │
│   │  (2420 bytes)│         │   (on-chain)     │         │   CONTRACT     │  │
│   └──────────────┘         └──────────────────┘         └────────────────┘  │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                          TRUST BOUNDARY                                      │
│                                                                             │
│   ✅ TRUSTED: Owner's device, Dilithium crypto, Vault contract logic       │
│   ⚠️ SEMI-TRUSTED: Attestation Oracle (availability only)                  │
│   ❌ UNTRUSTED: External callers, Adversaries                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Threat Matrix

| Threat Actor | Attack Vector | Impact | Mitigation | Residual Risk |
|--------------|---------------|--------|------------|---------------|
| **Quantum Adversary** | Extract ECDSA private key | Fund theft | Post-quantum signatures (Dilithium) | **None** (crypto assumption) |
| **Classical Adversary** | Replay signature | Double-spend | `consumedSignatures` mapping | **None** (tested) |
| **Malicious Oracle** | Refuse to attest | Denial of service | Multi-oracle future upgrade | **Availability only** |
| **Malicious Oracle** | Forge attestation | Fund theft | Cannot generate valid Dilithium sig | **None** |
| **Compromised L2** | Censor transactions | Delayed access | Funds remain on-chain | **Availability only** |
| **Contract Bug** | Logic exploit | Fund theft | Test suite, audits | **Low** (mitigated) |
| **Owner Device Hack** | Steal private key | Fund theft | Out of scope (user responsibility) | **Accepted** |

---

## Security Invariants (Summary)

| ID | Invariant | Test Verified |
|----|-----------|---------------|
| **I1** | No execution without valid PQ signature | ✅ `test_RevertWhen_SignatureNotAttested` |
| **I2** | One signature = one execution max | ✅ `test_RevertWhen_SignatureReplay` |
| **I3** | Oracle cannot steal funds | ✅ `test_RevertWhen_NonVerifierAttemptAttestation` |
| **I4** | Expired attestations rejected | ✅ `test_RevertWhen_AttestationExpired` |
| **I5** | Cross-vault replay impossible | ✅ Attestation key includes vault address |

---

## Trust Assumptions

```
┌────────────────────────────────────────────────────────────────┐
│                    EXPLICIT TRUST MODEL                        │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  OWNER must:                                                   │
│    • Securely store Dilithium private key                     │
│    • Not share key with anyone                                │
│    • Accept device compromise = vault compromise              │
│                                                                │
│  ORACLE can:                                                   │
│    • Attest valid signatures                                  │
│    • Delay/refuse attestations (availability impact)          │
│                                                                │
│  ORACLE cannot:                                                │
│    • Generate valid Dilithium signatures                      │
│    • Bypass vault validation logic                            │
│    • Execute transactions                                     │
│    • Steal funds                                              │
│                                                                │
│  VAULT guarantees:                                             │
│    • Signature size validation                                 │
│    • Attestation freshness check                              │
│    • One-time signature consumption                           │
│    • Cross-vault isolation                                     │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Attack Surface Summary

| Component | Lines of Code | Critical Functions | Risk Level |
|-----------|---------------|-------------------|------------|
| `SanctuaryVault.sol` | ~340 | 5 | Medium |
| `sanctuary-signer` (Rust) | ~260 | 3 | Low (well-tested crypto) |

---

## Reviewer Checklist

- [ ] Verify `_computeAttestationKey` includes all binding elements
- [ ] Confirm `consumedSignatures` prevents replay
- [ ] Check `ATTESTATION_VALIDITY` expiry logic
- [ ] Validate oracle-only access on `submitAttestation`
- [ ] Review `execute()` access control

---

**Document Version:** v0.2  
**Last Updated:** 2025-12-25
