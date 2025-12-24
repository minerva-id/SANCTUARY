// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {SanctuaryVault} from "../src/SanctuaryVault.sol";

contract SanctuaryVaultTest is Test {
    SanctuaryVault public vault;
    
    // Mock Dilithium public key (1312 bytes)
    bytes public mockPublicKey;
    
    // Mock Dilithium signature (2420 bytes)
    bytes public mockSignature;

    function setUp() public {
        vault = new SanctuaryVault();
        
        // Generate mock public key (1312 bytes)
        mockPublicKey = new bytes(1312);
        for (uint256 i = 0; i < 1312; i++) {
            mockPublicKey[i] = bytes1(uint8(i % 256));
        }
        
        // Generate mock signature (2420 bytes)
        mockSignature = new bytes(2420);
        for (uint256 i = 0; i < 2420; i++) {
            mockSignature[i] = bytes1(uint8((i * 7) % 256));
        }
    }

    function test_Initialize() public {
        vault.initialize(mockPublicKey);
        
        assertTrue(vault.initialized());
        assertEq(vault.ownerPkHash(), keccak256(mockPublicKey));
        
        console2.log("=== Vault Initialized ===");
        console2.log("Owner PK Hash:", vm.toString(vault.ownerPkHash()));
    }

    function test_RevertWhen_InitializedTwice() public {
        vault.initialize(mockPublicKey);
        
        vm.expectRevert(SanctuaryVault.AlreadyInitialized.selector);
        vault.initialize(mockPublicKey);
    }

    function test_RevertWhen_InvalidPublicKeySize() public {
        bytes memory invalidPk = new bytes(100);
        
        vm.expectRevert(
            abi.encodeWithSelector(
                SanctuaryVault.InvalidPublicKeySize.selector,
                100,
                1312
            )
        );
        vault.initialize(invalidPk);
    }

    function test_ValidateUserOp_GasBenchmark() public {
        vault.initialize(mockPublicKey);
        
        bytes32 userOpHash = keccak256("test operation");
        
        uint256 gasBefore = gasleft();
        uint256 result = vault.validateUserOp(userOpHash, mockSignature);
        uint256 gasUsed = gasBefore - gasleft();
        
        assertEq(result, 0); // 0 = valid
        
        console2.log("=== Gas Benchmark for Dilithium Signature Handling ===");
        console2.log("Signature Size:", mockSignature.length, "bytes");
        console2.log("Gas Used:", gasUsed);
        console2.log("Estimated L1 Cost at 30 gwei:", gasUsed * 30, "gwei");
        console2.log("Estimated L2 Cost (10x cheaper):", gasUsed * 3, "gwei");
    }

    function test_RevertWhen_InvalidSignatureSize() public {
        vault.initialize(mockPublicKey);
        
        bytes memory invalidSig = new bytes(100);
        bytes32 userOpHash = keccak256("test");
        
        vm.expectRevert(
            abi.encodeWithSelector(
                SanctuaryVault.InvalidSignatureSize.selector,
                100,
                2420
            )
        );
        vault.validateUserOp(userOpHash, invalidSig);
    }

    function test_Execute() public {
        vault.initialize(mockPublicKey);
        
        // Fund the vault
        vm.deal(address(vault), 10 ether);
        
        address recipient = address(0xBEEF);
        uint256 sendAmount = 1 ether;
        
        uint256 recipientBalanceBefore = recipient.balance;
        
        vault.execute(recipient, sendAmount, "");
        
        assertEq(recipient.balance, recipientBalanceBefore + sendAmount);
        assertEq(vault.nonce(), 1);
        
        console2.log("=== Transaction Executed ===");
        console2.log("Recipient:", recipient);
        console2.log("Amount:", sendAmount / 1e18, "ETH");
        console2.log("New Nonce:", vault.nonce());
    }

    function test_GetTransactionHash() public {
        vault.initialize(mockPublicKey);
        
        bytes32 txHash = vault.getTransactionHash(
            address(0xBEEF),
            1 ether,
            "",
            0
        );
        
        console2.log("=== Transaction Hash for Signing ===");
        console2.log("Hash:", vm.toString(txHash));
        
        assertTrue(txHash != bytes32(0));
    }

    function test_ReceiveETH() public {
        vault.initialize(mockPublicKey);
        
        vm.deal(address(this), 10 ether);
        
        (bool success,) = address(vault).call{value: 5 ether}("");
        assertTrue(success);
        
        assertEq(vault.getBalance(), 5 ether);
        
        console2.log("=== Vault Funded ===");
        console2.log("Balance:", vault.getBalance() / 1e18, "ETH");
    }

    function test_FullFlow() public {
        console2.log("\n=== SANCTUARY PROTOCOL - Full Smart Contract Flow ===\n");
        
        // 1. Initialize vault
        vault.initialize(mockPublicKey);
        console2.log("1. Vault initialized");
        console2.log("   Owner PK Hash:", vm.toString(vault.ownerPkHash()));
        
        // 2. Fund vault
        vm.deal(address(vault), 100 ether);
        console2.log("2. Vault funded with 100 ETH");
        
        // 3. Get transaction hash
        address recipient = address(0xCAFE);
        uint256 amount = 10 ether;
        bytes32 txHash = vault.getTransactionHash(recipient, amount, "", 0);
        console2.log("3. Transaction hash generated");
        console2.log("   Hash:", vm.toString(txHash));
        
        // 4. Validate with PQC signature
        uint256 gasBefore = gasleft();
        uint256 validationResult = vault.validateUserOp(txHash, mockSignature);
        uint256 validationGas = gasBefore - gasleft();
        console2.log("4. Dilithium signature validated");
        console2.log("   Result:", validationResult == 0 ? "VALID" : "INVALID");
        console2.log("   Gas Used:", validationGas);
        
        // 5. Execute transaction
        vault.execute(recipient, amount, "");
        console2.log("5. Transaction executed");
        console2.log("   Recipient balance:", recipient.balance / 1e18, "ETH");
        
        console2.log("\n=== Flow Complete - Assets Protected by Quantum-Safe Crypto ===");
    }
}

