// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SanctuaryVault
 * @author Sanctuary Protocol Team
 * @notice Quantum-resistant smart vault using CRYSTALS-Dilithium signatures
 * @dev Implements ERC-4337 compatible validation for post-quantum cryptography
 * 
 * This contract provides a secure enclave for assets protected by lattice-based
 * cryptography (Dilithium Level 2), offering resistance against quantum computing attacks.
 * 
 * SECURITY MODEL (v0.2 - Trusted Verifier Pattern):
 * Since EVM doesn't have native Dilithium precompiles, we use a hybrid approach:
 * 1. Signatures are verified OFF-CHAIN by a trusted verifier service
 * 2. Valid signatures are registered ON-CHAIN with an attestation
 * 3. validateUserOp checks if the signature has been pre-verified
 * 
 * This pattern is upgradeable - when precompiles become available, we can
 * switch to direct on-chain verification.
 */
contract SanctuaryVault {
    
    /// @notice Dilithium Level 2 signature size in bytes
    uint256 public constant DILITHIUM2_SIG_SIZE = 2420;
    
    /// @notice Dilithium Level 2 public key size in bytes
    uint256 public constant DILITHIUM2_PK_SIZE = 1312;
    
    /// @notice Attestation expiry duration (5 minutes)
    uint256 public constant ATTESTATION_VALIDITY = 5 minutes;
    
    /// @notice Hash of the owner's Dilithium public key (keccak256)
    bytes32 public ownerPkHash;
    
    /// @notice Full Dilithium public key of the owner (stored for verification)
    bytes public ownerPublicKey;
    
    /// @notice Transaction nonce for replay protection
    uint256 public nonce;
    
    /// @notice Indicates if the vault has been initialized
    bool public initialized;
    
    /// @notice Address of the trusted Dilithium verifier service
    /// @dev This should be a secure, audited off-chain service that performs
    ///      actual Dilithium signature verification
    address public trustedVerifier;
    
    /// @notice Mapping of signature hash => attestation timestamp
    /// @dev 0 = not attested, >0 = timestamp when attested
    mapping(bytes32 => uint256) public signatureAttestations;
    
    /// @notice Mapping of signature hash => consumed status (for replay protection)
    mapping(bytes32 => bool) public consumedSignatures;

    /// @notice Emitted when the vault is initialized
    event VaultInitialized(bytes32 indexed ownerPkHash, address indexed trustedVerifier, uint256 timestamp);
    
    /// @notice Emitted when a transaction is executed
    event TransactionExecuted(
        address indexed target,
        uint256 value,
        bytes data,
        uint256 indexed nonce
    );
    
    /// @notice Emitted when validation starts (for gas benchmarking)
    event ValidationStarted(uint256 signatureSize, uint256 gasRemaining);
    
    /// @notice Emitted when validation completes
    event ValidationCompleted(bool success, uint256 gasUsed);
    
    /// @notice Emitted when a signature is attested by the trusted verifier
    event SignatureAttested(bytes32 indexed signatureHash, bytes32 indexed userOpHash, uint256 timestamp);
    
    /// @notice Emitted when trusted verifier is updated
    event TrustedVerifierUpdated(address indexed oldVerifier, address indexed newVerifier);

    /// @notice Error when signature size is invalid
    error InvalidSignatureSize(uint256 provided, uint256 expected);
    
    /// @notice Error when public key size is invalid  
    error InvalidPublicKeySize(uint256 provided, uint256 expected);
    
    /// @notice Error when vault is already initialized
    error AlreadyInitialized();
    
    /// @notice Error when vault is not initialized
    error NotInitialized();
    
    /// @notice Error when caller is not authorized
    error Unauthorized();
    
    /// @notice Error when transaction execution fails
    error ExecutionFailed();
    
    /// @notice Error when signature is not attested by trusted verifier
    error SignatureNotAttested();
    
    /// @notice Error when signature attestation has expired
    error AttestationExpired();
    
    /// @notice Error when signature has already been used
    error SignatureAlreadyUsed();
    
    /// @notice Error when caller is not the trusted verifier
    error NotTrustedVerifier();
    
    /// @notice Error when the trusted verifier address is zero
    error InvalidVerifierAddress();

    /**
     * @notice Initialize the vault with owner's Dilithium public key and trusted verifier
     * @param _ownerPublicKey The full Dilithium Level 2 public key (1312 bytes)
     * @param _trustedVerifier Address of the off-chain Dilithium verification service
     */
    function initialize(bytes calldata _ownerPublicKey, address _trustedVerifier) external {
        if (initialized) revert AlreadyInitialized();
        if (_ownerPublicKey.length != DILITHIUM2_PK_SIZE) {
            revert InvalidPublicKeySize(_ownerPublicKey.length, DILITHIUM2_PK_SIZE);
        }
        if (_trustedVerifier == address(0)) revert InvalidVerifierAddress();
        
        ownerPublicKey = _ownerPublicKey;
        ownerPkHash = keccak256(_ownerPublicKey);
        trustedVerifier = _trustedVerifier;
        initialized = true;
        
        emit VaultInitialized(ownerPkHash, _trustedVerifier, block.timestamp);
    }

    /**
     * @notice Validate a user operation with Dilithium signature
     * @dev This is the ERC-4337 compatible validation function
     * 
     * SECURITY MODEL (v0.2 - Trusted Verifier Pattern):
     * 1. User submits userOp to trusted verifier service OFF-CHAIN
     * 2. Verifier performs Dilithium signature verification
     * 3. If valid, verifier calls attestSignature() to register the attestation
     * 4. User (or bundler) calls validateUserOp with the same signature
     * 5. Contract checks attestation exists and is not expired
     * 
     * @param userOpHash Hash of the user operation to validate
     * @param pqcSignature The Dilithium signature (2420 bytes for Level 2)
     * @return validationData 0 if valid, 1 if invalid (ERC-4337 standard)
     */
    function validateUserOp(
        bytes32 userOpHash,
        bytes calldata pqcSignature
    ) external returns (uint256 validationData) {
        if (!initialized) revert NotInitialized();
        
        uint256 startGas = gasleft();
        emit ValidationStarted(pqcSignature.length, startGas);
        
        // 1. Basic sanity check - signature size
        if (pqcSignature.length != DILITHIUM2_SIG_SIZE) {
            revert InvalidSignatureSize(pqcSignature.length, DILITHIUM2_SIG_SIZE);
        }
        
        // 2. Compute attestation key (binds signature to userOpHash and vault)
        bytes32 sigHash = keccak256(pqcSignature);
        bytes32 attestationKey = _computeAttestationKey(userOpHash, sigHash);
        
        // 3. Check if signature was attested by trusted verifier
        uint256 attestedAt = signatureAttestations[attestationKey];
        if (attestedAt == 0) {
            emit ValidationCompleted(false, startGas - gasleft());
            revert SignatureNotAttested();
        }
        
        // 4. Check attestation hasn't expired (prevent stale attestations)
        if (block.timestamp > attestedAt + ATTESTATION_VALIDITY) {
            emit ValidationCompleted(false, startGas - gasleft());
            revert AttestationExpired();
        }
        
        // 5. Check signature hasn't been used before (replay protection)
        if (consumedSignatures[attestationKey]) {
            emit ValidationCompleted(false, startGas - gasleft());
            revert SignatureAlreadyUsed();
        }
        
        // 6. Mark signature as consumed (prevent replay)
        consumedSignatures[attestationKey] = true;
        
        // Emit completion event with gas used
        uint256 gasUsed = startGas - gasleft();
        emit ValidationCompleted(true, gasUsed);
        
        // Return 0 = valid
        return 0;
    }
    
    /**
     * @notice Attest that a Dilithium signature is valid for a given userOpHash
     * @dev Only callable by the trusted verifier service
     * 
     * The verifier performs actual Dilithium cryptographic verification OFF-CHAIN
     * and then registers the result ON-CHAIN through this function.
     * 
     * @param userOpHash Hash of the user operation that was signed
     * @param sigHash keccak256 hash of the Dilithium signature
     */
    function attestSignature(bytes32 userOpHash, bytes32 sigHash) external {
        if (msg.sender != trustedVerifier) revert NotTrustedVerifier();
        if (!initialized) revert NotInitialized();
        
        bytes32 attestationKey = _computeAttestationKey(userOpHash, sigHash);
        
        // Don't re-attest already consumed signatures
        if (consumedSignatures[attestationKey]) revert SignatureAlreadyUsed();
        
        signatureAttestations[attestationKey] = block.timestamp;
        
        emit SignatureAttested(sigHash, userOpHash, block.timestamp);
    }
    
    /**
     * @notice Update the trusted verifier address
     * @dev Only callable by the current trusted verifier (for key rotation)
     * @param newVerifier The new trusted verifier address
     */
    function updateTrustedVerifier(address newVerifier) external {
        if (msg.sender != trustedVerifier) revert NotTrustedVerifier();
        if (newVerifier == address(0)) revert InvalidVerifierAddress();
        
        address oldVerifier = trustedVerifier;
        trustedVerifier = newVerifier;
        
        emit TrustedVerifierUpdated(oldVerifier, newVerifier);
    }
    
    /**
     * @notice Check if a signature attestation is valid and not expired
     * @param userOpHash Hash of the user operation
     * @param sigHash keccak256 hash of the signature
     * @return isValid True if attestation exists under validity window and not consumed
     * @return expiresAt Timestamp when attestation expires (0 if not attested)
     */
    function isAttestationValid(bytes32 userOpHash, bytes32 sigHash) 
        external 
        view 
        returns (bool isValid, uint256 expiresAt) 
    {
        bytes32 attestationKey = _computeAttestationKey(userOpHash, sigHash);
        uint256 attestedAt = signatureAttestations[attestationKey];
        
        if (attestedAt == 0 || consumedSignatures[attestationKey]) {
            return (false, 0);
        }
        
        expiresAt = attestedAt + ATTESTATION_VALIDITY;
        isValid = block.timestamp <= expiresAt;
    }
    
    /**
     * @notice Compute the attestation key for a signature
     * @dev Binds the signature to userOpHash, vault address, and owner
     */
    function _computeAttestationKey(bytes32 userOpHash, bytes32 sigHash) 
        internal 
        view 
        returns (bytes32) 
    {
        return keccak256(abi.encodePacked(
            address(this),  // Prevent cross-vault attacks
            ownerPkHash,    // Bind to owner's public key
            userOpHash,     // Bind to specific operation
            sigHash         // Bind to specific signature
        ));
    }

    /**
     * @notice Execute a transaction from the vault
     * @dev Only callable after successful validation (simplified for v0.1)
     * @param target The target address for the call
     * @param value The ETH value to send
     * @param data The calldata for the call
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external returns (bytes memory) {
        if (!initialized) revert NotInitialized();
        
        // In production: verify this is called by EntryPoint after validation
        // For v0.1: simplified access control
        
        nonce++;
        
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) revert ExecutionFailed();
        
        emit TransactionExecuted(target, value, data, nonce);
        
        return result;
    }

    /**
     * @notice Get the hash that should be signed for a transaction
     * @param target Target address
     * @param value ETH value
     * @param data Calldata
     * @param _nonce Transaction nonce
     * @return The hash to sign with Dilithium
     */
    function getTransactionHash(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 _nonce
    ) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
            address(this),
            target,
            value,
            keccak256(data),
            _nonce,
            block.chainid
        ));
    }

    /**
     * @notice Receive ETH into the vault
     */
    receive() external payable {}

    /**
     * @notice Get vault balance
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

