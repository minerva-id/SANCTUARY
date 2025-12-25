//! Generate deterministic test data for Solidity integration testing

use pqcrypto_dilithium::dilithium2::{
    detached_sign, keypair, verify_detached_signature,
    DetachedSignature, PublicKey, SecretKey,
};
use pqcrypto_traits::sign::{
    DetachedSignature as DetachedSignatureTrait, PublicKey as PublicKeyTrait,
    SecretKey as SecretKeyTrait,
};

fn main() {
    println!("=== SANCTUARY PROTOCOL - Solidity Integration Data ===\n");
    
    // Create wallet
    let (pk, sk) = keypair();
    let pk_bytes = pk.as_bytes();
    let sk_bytes = sk.as_bytes();
    
    println!("📦 PUBLIC KEY (for mockPublicKey in Solidity):");
    println!("Size: {} bytes", pk_bytes.len());
    println!("\nmockPublicKey = hex\"{}\";", hex::encode(pk_bytes));
    
    // Create a deterministic message (userOpHash simulation)
    let user_op_hash = b"sanctuary_test_user_operation_hash_v1";
    
    // Sign
    let signature = detached_sign(user_op_hash, &sk);
    let sig_bytes = signature.as_bytes();
    
    println!("\n\n📝 SIGNATURE (for mockSignature in Solidity):");
    println!("Size: {} bytes", sig_bytes.len());
    println!("\nmockSignature = hex\"{}\";", hex::encode(sig_bytes));
    
    // Verify it works
    let sig_check = DetachedSignature::from_bytes(sig_bytes).unwrap();
    let pk_check = PublicKey::from_bytes(pk_bytes).unwrap();
    let is_valid = verify_detached_signature(&sig_check, user_op_hash, &pk_check).is_ok();
    
    println!("\n\n✅ VERIFICATION CHECK:");
    println!("Message: {:?}", String::from_utf8_lossy(user_op_hash));
    println!("Signature Valid: {}", is_valid);
    
    // Also print keccak256 hash for comparison (simple hash for now)
    let mut pk_hash = [0u8; 32];
    for (i, chunk) in pk_bytes.chunks(32).enumerate() {
        for (j, &byte) in chunk.iter().enumerate() {
            if j < 32 {
                pk_hash[j] ^= byte.wrapping_add(i as u8);
            }
        }
    }
    println!("\nPublic Key Hash (simple): 0x{}", hex::encode(&pk_hash));
    
    println!("\n=== COPY THE hex\"...\" VALUES ABOVE TO SanctuaryVault.t.sol ===");
}
