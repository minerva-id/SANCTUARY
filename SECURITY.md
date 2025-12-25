# 🔐 SECURITY POLICY — SANCTUARY PROTOCOL

**Document:** `SECURITY.md`  
**Status:** Active  
**Applies to:** Smart Contracts, Signer, Verifier Interfaces

---

## 1. Security Philosophy

Sanctuary is designed as a **safety-first, availability-second** protocol.

The protocol intentionally prioritizes:
- asset integrity
- cryptographic correctness
- explicit trust boundaries

over:
- convenience
- transaction liveness
- retail UX optimization

This document defines Sanctuary’s security assumptions, threat boundaries, and disclosure process.

---

## 2. Threat Model Summary

Sanctuary explicitly defends against:

- 🔮 **Quantum-capable adversaries** attempting key extraction
- 🔁 **Signature replay attacks**
- 🧩 **Cross-vault signature reuse**
- 🕵️ **Malicious verifiers attempting fund theft**
- ⚙️ **Incorrect or malformed signatures**

Sanctuary does **not** attempt to defend against every class of attack. See Section 5.

---

## 3. Trust Assumptions (Explicit)

Sanctuary v0.2 operates under the following assumptions:

### 3.1 Owner Assumptions

- The owner securely stores their Dilithium private key
- Compromise of the owner’s device compromises the vault

---

### 3.2 Verifier Assumptions

- Verifiers are authorized to attest signature validity
- Verifiers **cannot**:
  - generate valid signatures
  - initiate execution
  - bypass vault logic

A compromised verifier may:
- refuse to attest
- delay attestations

**Impact:** loss of availability, not loss of funds

---

### 3.3 Blockchain Assumptions

- Ethereum Layer-2 executes contracts correctly
- Consensus failures may affect availability
- Contract state integrity remains preserved

---

## 4. Security Guarantees

Given the assumptions above, Sanctuary guarantees:

- ❌ No asset movement without a valid post-quantum signature
- 🔐 Private keys never appear on-chain
- 🔁 Signatures are single-use
- 🧱 Vault isolation prevents cross-instance attacks

---

## 5. Known Limitations (Non-Goals)

Sanctuary does **not** protect against:

- ❗ Device-level malware or key exfiltration
- ❗ Social engineering attacks
- ❗ Denial-of-service by verifiers or sequencers
- ❗ Loss of private keys (no recovery)

These are **explicit design trade-offs**, not oversights.

---

## 6. Responsible Disclosure

We welcome security researchers to report vulnerabilities responsibly.

### Reporting Process

- Do **not** open public GitHub issues for security bugs.
- Please report sensitive bugs via the **GitHub Security Advisories** tab (Private Reporting).

**How to submit a report:**
1. Navigate to the **Security** tab in this repository.
2. Click on **"Report a vulnerability"**.
3. Draft and submit your advisory privately.

Include:
- clear reproduction steps
- potential impact analysis
- proof-of-concept if possible

---

## 7. Bug Bounty Status

- Bug bounty program: **Planned**
- Scope definition: **Pending**
- Rewards: **To be announced**

---

## 8. Audit Status

- Independent audits: **Not yet conducted**
- Internal test coverage: **Extensive (Forge test suite)**

Audit reports will be published publicly once available.

---

## 9. Versioning & Changes

Security assumptions may evolve as:
- multi-verifier attestations are introduced
- native post-quantum precompiles become available

Material changes will be documented explicitly.

---

## 10. Final Note

Sanctuary does not promise absolute security.

It promises **honest security** — with clearly defined guarantees, limitations, and responsibilities.

> *Security is not the absence of risk, but the absence of ambiguity.*

