//! Sanctuary Signer - Quantum-Resistant Wallet using CRYSTALS-Dilithium
//!
//! This library provides quantum-safe cryptographic signing capabilities
//! for the Sanctuary Protocol on Ethereum Layer-2.

use pqcrypto_dilithium::dilithium2::{
    detached_sign, keypair, verify_detached_signature,
    DetachedSignature, PublicKey, SecretKey,
};
use pqcrypto_traits::sign::{
    DetachedSignature as DetachedSignatureTrait, PublicKey as PublicKeyTrait,
    SecretKey as SecretKeyTrait,
};
use serde::{Deserialize, Serialize};

/// Ukuran signature Dilithium Level 2 dalam bytes
pub const DILITHIUM2_SIG_SIZE: usize = 2420;
/// Ukuran public key Dilithium Level 2 dalam bytes  
pub const DILITHIUM2_PK_SIZE: usize = 1312;
/// Ukuran secret key Dilithium Level 2 dalam bytes
pub const DILITHIUM2_SK_SIZE: usize = 2560;

/// Error types untuk SanctuaryWallet
#[derive(Debug, Clone, PartialEq)]
pub enum SanctuaryError {
    InvalidPublicKeySize,
    InvalidSecretKeySize,
    InvalidSignatureSize,
    SignatureVerificationFailed,
    KeyDeserializationFailed,
}

/// SanctuaryWallet - Quantum-resistant wallet menggunakan CRYSTALS-Dilithium
#[derive(Clone)]
pub struct SanctuaryWallet {
    pk: Vec<u8>,
    sk: Vec<u8>,
}

impl SanctuaryWallet {
    /// Generate wallet baru dengan keypair Dilithium yang quantum-safe
    pub fn new() -> Self {
        let (pk, sk) = keypair();
        SanctuaryWallet {
            pk: pk.as_bytes().to_vec(),
            sk: sk.as_bytes().to_vec(),
        }
    }

    /// Mendapatkan public key dalam format bytes
    pub fn public_key(&self) -> &[u8] {
        &self.pk
    }

    /// Mendapatkan public key dalam format hex string
    pub fn public_key_hex(&self) -> String {
        hex::encode(&self.pk)
    }

    /// Mendapatkan hash dari public key (untuk ownerImg di Smart Contract)
    pub fn public_key_hash(&self) -> [u8; 32] {
        // Simple hash menggunakan keccak256-like approach
        // Untuk production, gunakan proper keccak256
        let mut hash = [0u8; 32];
        for (i, chunk) in self.pk.chunks(32).enumerate() {
            for (j, &byte) in chunk.iter().enumerate() {
                if j < 32 {
                    hash[j] ^= byte.wrapping_add(i as u8);
                }
            }
        }
        hash
    }

    /// Sign pesan/transaksi dengan Dilithium signature
    /// Returns: Detached signature (2420 bytes untuk Level 2)
    pub fn sign_transaction(&self, message: &[u8]) -> Result<Vec<u8>, SanctuaryError> {
        // Reconstruct secret key from bytes
        let sk = SecretKey::from_bytes(&self.sk)
            .map_err(|_| SanctuaryError::KeyDeserializationFailed)?;
        
        let signature = detached_sign(message, &sk);
        Ok(signature.as_bytes().to_vec())
    }

    /// Verify signature (simulasi apa yang akan dilakukan Smart Contract)
    pub fn verify_transaction(
        pk_bytes: &[u8],
        message: &[u8],
        signature_bytes: &[u8],
    ) -> Result<bool, SanctuaryError> {
        // Validate sizes
        if pk_bytes.len() != DILITHIUM2_PK_SIZE {
            return Err(SanctuaryError::InvalidPublicKeySize);
        }
        if signature_bytes.len() != DILITHIUM2_SIG_SIZE {
            return Err(SanctuaryError::InvalidSignatureSize);
        }

        // Reconstruct public key and signature
        let pk = PublicKey::from_bytes(pk_bytes)
            .map_err(|_| SanctuaryError::KeyDeserializationFailed)?;
        let sig = DetachedSignature::from_bytes(signature_bytes)
            .map_err(|_| SanctuaryError::KeyDeserializationFailed)?;

        // Verify
        match verify_detached_signature(&sig, message, &pk) {
            Ok(()) => Ok(true),
            Err(_) => Ok(false),
        }
    }
}

impl Default for SanctuaryWallet {
    fn default() -> Self {
        Self::new()
    }
}

/// Struktur untuk serialisasi transaksi yang akan dikirim ke blockchain
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SanctuaryTransaction {
    /// Target address (hex encoded)
    pub to: String,
    /// Value dalam wei
    pub value: u128,
    /// Calldata (hex encoded)
    pub data: String,
    /// Nonce untuk replay protection
    pub nonce: u64,
}

impl SanctuaryTransaction {
    /// Encode transaksi menjadi bytes untuk signing
    pub fn encode(&self) -> Vec<u8> {
        let mut encoded = Vec::new();
        encoded.extend_from_slice(self.to.as_bytes());
        encoded.extend_from_slice(&self.value.to_be_bytes());
        encoded.extend_from_slice(self.data.as_bytes());
        encoded.extend_from_slice(&self.nonce.to_be_bytes());
        encoded
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wallet_creation() {
        let wallet = SanctuaryWallet::new();
        
        println!("=== Sanctuary Wallet Created ===");
        println!("Public Key Size: {} bytes", wallet.public_key().len());
        println!("Public Key (first 64 chars): {}...", &wallet.public_key_hex()[..64]);
        
        assert_eq!(wallet.public_key().len(), DILITHIUM2_PK_SIZE);
    }

    #[test]
    fn test_sign_and_verify() {
        let wallet = SanctuaryWallet::new();
        let message = b"Transfer 100 ETH to Alice";

        // Sign
        let signature = wallet.sign_transaction(message).expect("Signing failed");
        
        println!("=== Quantum-Safe Transaction Signed ===");
        println!("Message: {:?}", String::from_utf8_lossy(message));
        println!("Signature Size: {} bytes", signature.len());
        println!("Signature (first 64 chars): {}...", &hex::encode(&signature)[..64]);

        assert_eq!(signature.len(), DILITHIUM2_SIG_SIZE);

        // Verify
        let is_valid = SanctuaryWallet::verify_transaction(
            wallet.public_key(),
            message,
            &signature,
        ).expect("Verification failed");

        println!("Signature Valid: {}", is_valid);
        assert!(is_valid);
    }

    #[test]
    fn test_invalid_signature_rejected() {
        let wallet = SanctuaryWallet::new();
        let message = b"Transfer 100 ETH to Alice";
        
        let mut signature = wallet.sign_transaction(message).expect("Signing failed");
        
        // Corrupt the signature
        signature[0] ^= 0xFF;
        
        let is_valid = SanctuaryWallet::verify_transaction(
            wallet.public_key(),
            message,
            &signature,
        ).expect("Verification failed");

        println!("Corrupted signature valid: {}", is_valid);
        assert!(!is_valid, "Corrupted signature should be rejected");
    }

    #[test]
    fn test_wrong_message_rejected() {
        let wallet = SanctuaryWallet::new();
        let message = b"Transfer 100 ETH to Alice";
        let wrong_message = b"Transfer 100 ETH to Bob";

        let signature = wallet.sign_transaction(message).expect("Signing failed");

        let is_valid = SanctuaryWallet::verify_transaction(
            wallet.public_key(),
            wrong_message,
            &signature,
        ).expect("Verification failed");

        println!("Wrong message signature valid: {}", is_valid);
        assert!(!is_valid, "Signature for wrong message should be rejected");
    }

    #[test]
    fn test_full_transaction_flow() {
        println!("\n=== SANCTUARY PROTOCOL - Full Transaction Flow ===\n");
        
        // 1. Create wallet
        let wallet = SanctuaryWallet::new();
        println!("1. Wallet Created");
        println!("   Public Key Hash: 0x{}", hex::encode(wallet.public_key_hash()));

        // 2. Create transaction
        let tx = SanctuaryTransaction {
            to: "0x742d35Cc6634C0532925a3b844Bc9e7595f8b2E1".to_string(),
            value: 1_000_000_000_000_000_000, // 1 ETH in wei
            data: "0x".to_string(),
            nonce: 1,
        };
        println!("2. Transaction Created");
        println!("   To: {}", tx.to);
        println!("   Value: {} wei", tx.value);

        // 3. Sign transaction
        let tx_bytes = tx.encode();
        let signature = wallet.sign_transaction(&tx_bytes).expect("Signing failed");
        println!("3. Transaction Signed");
        println!("   Signature Size: {} bytes", signature.len());

        // 4. Verify (simulating Smart Contract)
        let is_valid = SanctuaryWallet::verify_transaction(
            wallet.public_key(),
            &tx_bytes,
            &signature,
        ).expect("Verification failed");
        println!("4. Signature Verified: {}", is_valid);

        println!("\n=== Transaction Ready for L2 Submission ===");
        println!("   Signature Hex: {}...", &hex::encode(&signature)[..100]);
        
        assert!(is_valid);
    }
}
