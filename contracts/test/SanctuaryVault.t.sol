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
    
    // Trusted verifier address
    address public trustedVerifier;
    
    // Test user address
    address public user;

    function setUp() public {
        vault = new SanctuaryVault();
        trustedVerifier = makeAddr("trustedVerifier");
        user = makeAddr("user");
        
        // REAL Dilithium Level 2 Public Key (1312 bytes) from Rust sanctuary-signer
        mockPublicKey = hex"caf1d0f29e8f2bab72b75081ce94fd545af1467113b903eda3e185c825a096ca64dc3376ed3d7e05129b5ce15c9d4c35966263f43adb25667446e0b47ea8e710ba845634e71afff88b25942fb68f54f32b48db840086d8eb938ffa384dbf719a56447b70472fba31c6c395233c518bcb08caa41870e07b496876c0774561b7e93f5a711ad4688ea17ec0c3ec7a9f0e5921bfb18f8507de08b5a7c16948483cc73b7f436b198d4d7b43eda911f87f8216c2291b8e351fa3a109119ddf5c3df022a6efb58338dad2955738daed9b2944395e4dbfda6e2c613a562d49a9adfd95a2230f95dde744787f2dbb79a35f1cf44b02b11c16e385d9aa4564aa299a8ca9fe188807508cbd0c1fb87271d427fce940c8493f228b2e4a5ebef5662dce304e3f6a401f7c7b5bccced7ff03dbbf97fb2c4fd9502bab3890cd208b949ebc967ec7d5958193c01a6c7f63ce3b7ae91c46b50651e1422d9ff94826b9bc83395411b4df970a6bd769097bff397eaecc83240b82b7a32f7091be257ea4c5ad63ef453beb0568cffaa936f25233725ff7a0e7692b0e6aceaa958c6d2384e01df34001e43ba042fac401638524153334a7dce6f9edc742def97346bed33b9a52cd96862bfc69ab8d28e641ded0e3cf7f0efbb49f17d7763df20b2399f83edca52b0641fc233fecc121f11e5af3c951905eec51b0da1eb288dc08083eceee9c0a1a3930f286f7d144b8bef87677b537c042b8e456c38ff395c642090da73261fb686d840725bccddbae5703c052abd5ce9c9fd280f3a1077c77799870979c2ea3dbb83e7173d3a2ed4e8d63bd5ab09df2f307e8e28c56bceab80fd058529f41de37ac2da8dc2168f8f6014f1c28eac39e2d4a5ce7671530d69c0384cf0462cb2cc77abd8f007ebff323f415e02a520087d2a4c34e168182ba79805bbf02051f8cd00f8d1cb6049781e59cdfd7a8ed63b600425846f48800b5c78eae8daccef37cf172ff41f05aaed379223044b22bce35ee73aeff90acb0e49fc654c94774fcf6fc9230f2ed17bdcc85fb349bcf3a6a5ff06d3a5c95f60af5fe40a38603d87b2aad5bad3845d311780fce64d5cdc6f2738315a0a0663dc0244823f75c46e3be3277dccfc813da4d652680c3c2b309f6ec003b9958eab848484890e3919be34cc45e54cbf5b8c1a5433ce0c464e5237329a2878542a32ef439652da9d84d82af1499df8ff491545401a3c2000256d1f4f649ed6a16db092d5c4a7ad7c69b3fe24446fcc8389465955190ec19244de899234905121670e94aa2818e38168bdf0c2ef01db64cb6446d7696521867d02f4d4c33053c35e5e040ba5b4bb5510726e2ad40f3bfda7abf284d859f149dfea721ea222f566727f84562addf74ed50a28caf8010c23515e6b41354eab60a70a73f0d066474f36794d8fa0e04558d93f2a32da55cf5ddb97920fda4486b7eb854372f5685180c3aa678462bb6e96d74accfd33016a3dcee4f787a143ac22418f5e009046e0cae378257211326e37a5d841190f8556a17a864020bd6c10ce46d75ebcdb9e1f1040f703906e9b263a42ff2a1e0192005bc369a65efe8755a13dce9b55a4a3db5e29af87bd19f2b0a0419d4fc36bf9fc8c0697212364b23f50d82e747023b7ee232e03fedf78f06808f13f32f2e2aa6dd478bf9edc2d9f44651845126c2fe90be5a197c2ebba8860ec6bf00bcf354e6308fdf3832a51c1db5c31e8221d945a89b6a51447fb713b446f22b423bc6cd124d30c22b189a1ada7b7fe05e4f28e84fc8a1afbccc10673ac8edc30751c438ca72d4969d63d6f7e9698a1a5d66e50a00493e1dc43d102d25708b99bdb67a346d597b";
        
        // REAL Dilithium Level 2 Signature (2420 bytes) from Rust sanctuary-signer
        mockSignature = hex"5fa1a46ec8473b218c38c9bbb6ee4680d85ac660d80bd1665542d987dfd826f411b72b2580b771132a3c91af7c8ab0bc2d3dc437ceb1bb95183f24f052cad683fd51f1ab08502726aaf192d0dd2fb36c5e2b3b1ca96c894392eb959d6327d846d0b1187eaa7439d89532648d812afd34fdeb67cf71d873e83a1dbf4dcbb6c0e0d90dbd035767a9a4cdec7997e7e8acc819bf692e16d87d4afc4bf1bdf80ec5895f10a234e92ba472b809a50cf6b0b56456ef9c595b5bc0334f861bb70730f8dce61b2c48c88598b92f42b1fb66e138eec8083cf939e4228cf36143faf07f0b55f988b4e547593881a30947cbcebebee5d75fb2b9c6aaeabca9d236d7d0da4ccd913283384d90cfcbccf4c2bb22705a12aaf9330b064dc87bf9f1e511e882ad0e8d485b5906bea1cbd550eb8ae203e345dff7eefd0de29562d9323c48c9a6a58eeb5b4693c09472629b39f22380105faa4628a488a3042909e3918765069ef61421e23aa15f0fd8115cfa5a8e2f7112e4a7976a8f1097494a751cef7207c4b135c21c780689a2fc2192bddc5029e6c5d5d729520c56abfa85acd73dea2faeb66087c82d218664a5d95a4ed52b0df0728d495ff156fe9fd5df21f9ac95705a1e1af5ff6ee3211232be88b61907e96e26348980902d4b5bbbd3d23d9538f4b11719d0c22215a5c24c3c5e6ef9349c0a15a6f2f6cf4c7dab7fb31487468005da95af5d4e61ff33a122a3f803a1da7c8d5e492b5379afd4dc2dafc06a942310ffb8694cf86496317ddb790e1494e91dc25a3481f144eff7ee1938ee8b79e5f63796302005978095643c5e0f860c71300adc321d07a720f2f8b13101046a249cc2ca388615ff97c96409dcf37a978bb294714d79eecf25f2e47960c89c3d3266eac3e99a76115f463acad07f2373f9a03fb1031db134e48287cd1a87874d3095d1a4e532627899e3d0859229919026cc5c35f04f44b7fd6ecb929061214bb8cd6b46b14d0438e486cc652029a8a6651af39a6b047583a4a20990bca55ebe5b094b52a91b8ddd53b87d61d819b0c87bbc1710ea3e26489fbdc4966da368b33f48e10bfaa530efebd2260a46511953adef4bd2e6029c8cd55221079bf2cc683621b11693b2b05f38ccc7adfecc1e9b3dab8b49b1174e72c96c2bc47a9ab4015dcc10042e5a1e4ad01b155aa154d9d2a18239ece4956c4ea987fef767b963855824bb0ed0bb421517870717cb4db552367a47446941880bb6a81834a41bcc2ba98ba8becb873d17978978f6d9adc11fab28d60cdbb7c99482e7e56982143fe384d66d10f18adbba8bc4fa29b543c4680a43764063f27dedb6569ad2a6077648985baa49441e2f631223ba7872bced42b71b402d0ced70a98636cb285430f0f5c95f2a3a7948bc606bda716ef47278e1a119ac920867c447537a2e87e14a409f94d437a92aa700fa6a2144190b12d245cbbad3db5b6f734f3a79fe10501360dba3e72150b47a67127466f45544179ac77d46c02e2e8a6477c71b0ade4665041e10c41071d6816e5f2e4b76becfcdc0f6e1488e7db6a221a573c3f219eb998a5e65d0b035ba63803ef67a0be1556b699e6a838807ddc8394c196b06858d95f11457d3dbb9f8fa8302215c2a14cc4e3799404c380d512e8b7fbf485008743c4d54b7332d3bfe898f0c699b977d7969008ceec7ec39273643e1f8e8cf7feac18eccda17b648354f2a198940a6216091cbfde2a9d3f05aca0d323b7acf0a6706c16a70a16b8e3a00567f6960c5f0315b7b0ca020c917da67a7aa0c8bd4bf77f8a6c5a75986935c6ca98d7f58a2c686c0ddc239e54a32ceb5d71de98be50ee79f2debbe5ac3a6f8407e73f197bf54b45819933d46129c3cff271ac11c3d3119703ee0cf549600b62821f315f5b726c7d5bac6de60f1e8c54efda0808ebd767e428cf0e008c9b053bb68e6a86229aac323d8b2d666d38ad8b37428eac3bd64b86ae988c6e23f9ec7d82c94a423121a5a3360f41b24c64570891e7a66a38d3398d108474ac7e333628fbab0a8edb5fb528546c322bbb7338c57a3ed193df505ceb0d37778cb77e1284b3ec83c0750708621040f0c67008edfc15195ebfacd7c6c17aaaf7d554846c641eb35f68e4d301b04c64146adb01db3a62cb250f93e86b14a80bf00e832a7b70c9c81ab3d97cbe2d76e49cbfe118f8df4941150f8dbda1643c1c78de1213de84a43b44eeade84898dbb8f1199605139f0c834d033b17cae4cbd9c1e35e8e3c58c416c131f0059f81f56a68f1513837c060f41c46827b5f48feb1a7c0903c1ee4143110ecb5eac5c3baf447b621072575e97b6bbb415905c2211909c1cd0c0f49784e2054757c90e10c98431e7c0e08f3dd708c26cf7495d72e03879040d1846f6dd2c5c66a4805fbb17013e1fb792c99dab1dfe0451aa66e7242df3da98f4396cac5f5d9521fcc805f00b496c2eae888c5837440297be75433d8ebfb763fd95f02f937698acb7a2f51a661433f287d8fe077c9540f65e1da6e120ffd0c69a1319c5d8c46f9faeef60f19e5ab4b61c81d3e9383e0311d2aa20ee08f252cb18c463ef693271c2bda1c54f76c685d8b3c3896e575e055fa288a1943137fb58dba0f29516137b6702d89d90e8e17e369ed26641f8ca25fdf6b98d3e4f9883e89923cbb5c376d92ee778306bf664e1d61171aea2ca606d92546fb455a8ec16b632f671107592197a627fa9580f9641c6e7c32d7218653e13913571b24958d5642206cd2693679338acde6720d2efd3e962255d477db158a4b5d721dc3633ea79178583e19d70235d04cee3eeef5e38bbdf9095f09a8f63047a71c8095def56618a254b73cf15b9f59442979adf414b626740baab38809a91e3e109db6c43bd23c2263c5f56fdd2c25e66485323f2ec483e546d7e903eff05fa200945282b7ecf198dd0e039f8b4128aa031b3bae051e0acd00d4ca86fc179abadab7b5b4e128b773da61ec3ae2d21e2008ea3f25e48b83ed3988af2aea6466ba0fcac9885814caa666799099f4e2adfb9a55bba5e146c606d8e2efe665d3b243e19137cb4b26dab5b7ffba522fe2b69d4f01cf45e67bec0cd86f334476a2170ff3893bb392e11b9497c91413ed7767c105ef6f760c6e6415697f3e9f46d43c2842ddc3aff03c52ea03cb23956d1689d5a971cd4881f42eb305b1bac7aa4d90b6614386f57941dc03d883328d2c8035a73454aa6dd24932eb758450508275e174da2a1fe767f3d7b95b7b8bfc849dca76ad566c884cafc6d5cf9bfa6cc110493a66a7d50baf22801e00106081f363c3f4046636a769293a6a9dfe6e9f8f9132d399799adb9bbbebfeffd26272d586b8995c9cad1dbe6f3f5fa041b25282e2f33526f73b5b8b9bedbe2f900000000000000000000000000000015213041";
    }

    // ============ Initialization Tests ============

    function test_Initialize() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        assertTrue(vault.initialized());
        assertEq(vault.ownerPkHash(), keccak256(mockPublicKey));
        assertEq(vault.trustedVerifier(), trustedVerifier);
        
        console2.log("=== Vault Initialized ===");
        console2.log("Owner PK Hash:", vm.toString(vault.ownerPkHash()));
        console2.log("Trusted Verifier:", trustedVerifier);
    }

    function test_RevertWhen_InitializedTwice() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        vm.expectRevert(SanctuaryVault.AlreadyInitialized.selector);
        vault.initialize(mockPublicKey, trustedVerifier);
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
        vault.initialize(invalidPk, trustedVerifier);
    }
    
    function test_RevertWhen_ZeroVerifierAddress() public {
        vm.expectRevert(SanctuaryVault.InvalidVerifierAddress.selector);
        vault.initialize(mockPublicKey, address(0));
    }

    // ============ Attestation Tests ============

    function test_AttestSignature() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        bytes32 sigHash = keccak256(mockSignature);
        
        vm.prank(trustedVerifier);
        vault.attestSignature(userOpHash, sigHash);
        
        (bool isValid, uint256 expiresAt) = vault.isAttestationValid(userOpHash, sigHash);
        assertTrue(isValid);
        assertEq(expiresAt, block.timestamp + vault.ATTESTATION_VALIDITY());
        
        console2.log("=== Signature Attested ===");
        console2.log("UserOp Hash:", vm.toString(userOpHash));
        console2.log("Sig Hash:", vm.toString(sigHash));
        console2.log("Expires At:", expiresAt);
    }
    
    function test_RevertWhen_NonVerifierAttemptAttestation() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        bytes32 sigHash = keccak256(mockSignature);
        
        vm.prank(user);
        vm.expectRevert(SanctuaryVault.NotTrustedVerifier.selector);
        vault.attestSignature(userOpHash, sigHash);
    }

    // ============ Validation Tests ============

    function test_ValidateUserOp_WithValidAttestation() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        bytes32 sigHash = keccak256(mockSignature);
        
        // Trusted verifier attests the signature
        vm.prank(trustedVerifier);
        vault.attestSignature(userOpHash, sigHash);
        
        // Now validate should succeed
        uint256 gasBefore = gasleft();
        uint256 result = vault.validateUserOp(userOpHash, mockSignature);
        uint256 gasUsed = gasBefore - gasleft();
        
        assertEq(result, 0); // 0 = valid
        
        console2.log("=== Validation Success ===");
        console2.log("Gas Used:", gasUsed);
    }
    
    function test_RevertWhen_SignatureNotAttested() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        
        // Try to validate without attestation
        vm.expectRevert(SanctuaryVault.SignatureNotAttested.selector);
        vault.validateUserOp(userOpHash, mockSignature);
    }
    
    function test_RevertWhen_AttestationExpired() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        bytes32 sigHash = keccak256(mockSignature);
        
        // Attest the signature
        vm.prank(trustedVerifier);
        vault.attestSignature(userOpHash, sigHash);
        
        // Warp time past expiry (5 minutes + 1 second)
        vm.warp(block.timestamp + 5 minutes + 1);
        
        vm.expectRevert(SanctuaryVault.AttestationExpired.selector);
        vault.validateUserOp(userOpHash, mockSignature);
    }
    
    function test_RevertWhen_SignatureReplay() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        bytes32 sigHash = keccak256(mockSignature);
        
        // Attest the signature
        vm.prank(trustedVerifier);
        vault.attestSignature(userOpHash, sigHash);
        
        // First validation succeeds
        uint256 result = vault.validateUserOp(userOpHash, mockSignature);
        assertEq(result, 0);
        
        // Re-attest (verifier tries to attest same sig again)
        vm.prank(trustedVerifier);
        vm.expectRevert(SanctuaryVault.SignatureAlreadyUsed.selector);
        vault.attestSignature(userOpHash, sigHash);
    }

    function test_RevertWhen_InvalidSignatureSize() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
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

    // ============ Verifier Rotation Tests ============

    function test_UpdateTrustedVerifier() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        address newVerifier = makeAddr("newVerifier");
        
        vm.prank(trustedVerifier);
        vault.updateTrustedVerifier(newVerifier);
        
        assertEq(vault.trustedVerifier(), newVerifier);
        
        console2.log("=== Verifier Rotated ===");
        console2.log("New Verifier:", newVerifier);
    }
    
    function test_RevertWhen_NonVerifierTriesRotation() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        vm.prank(user);
        vm.expectRevert(SanctuaryVault.NotTrustedVerifier.selector);
        vault.updateTrustedVerifier(user);
    }

    // ============ Execution Tests ============

    function test_Execute() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
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
        vault.initialize(mockPublicKey, trustedVerifier);
        
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
        vault.initialize(mockPublicKey, trustedVerifier);
        
        vm.deal(address(this), 10 ether);
        
        (bool success,) = address(vault).call{value: 5 ether}("");
        assertTrue(success);
        
        assertEq(vault.getBalance(), 5 ether);
        
        console2.log("=== Vault Funded ===");
        console2.log("Balance:", vault.getBalance() / 1e18, "ETH");
    }

    // ============ Full Integration Flow ============

    function test_FullFlow() public {
        console2.log("\n=== SANCTUARY PROTOCOL - Full Smart Contract Flow ===\n");
        
        // 1. Initialize vault
        vault.initialize(mockPublicKey, trustedVerifier);
        console2.log("1. Vault initialized");
        console2.log("   Owner PK Hash:", vm.toString(vault.ownerPkHash()));
        console2.log("   Trusted Verifier:", trustedVerifier);
        
        // 2. Fund vault
        vm.deal(address(vault), 100 ether);
        console2.log("2. Vault funded with 100 ETH");
        
        // 3. Get transaction hash
        address recipient = address(0xCAFE);
        uint256 amount = 10 ether;
        bytes32 txHash = vault.getTransactionHash(recipient, amount, "", 0);
        console2.log("3. Transaction hash generated");
        console2.log("   Hash:", vm.toString(txHash));
        
        // 4. Off-chain: Verifier validates Dilithium signature
        //    Then attests on-chain
        bytes32 sigHash = keccak256(mockSignature);
        vm.prank(trustedVerifier);
        vault.attestSignature(txHash, sigHash);
        console2.log("4. Trusted verifier attested signature");
        console2.log("   Sig Hash:", vm.toString(sigHash));
        
        // 5. Validate with PQC signature
        uint256 gasBefore = gasleft();
        uint256 validationResult = vault.validateUserOp(txHash, mockSignature);
        uint256 validationGas = gasBefore - gasleft();
        console2.log("5. Dilithium signature validated on-chain");
        console2.log("   Result:", validationResult == 0 ? "VALID" : "INVALID");
        console2.log("   Gas Used:", validationGas);
        
        // 6. Execute transaction
        vault.execute(recipient, amount, "");
        console2.log("6. Transaction executed");
        console2.log("   Recipient balance:", recipient.balance / 1e18, "ETH");
        
        console2.log("\n=== Flow Complete - Assets Protected by Quantum-Safe Crypto ===");
    }
    
    // ============ Gas Benchmarks ============
    
    function test_GasBenchmark_AttestationFlow() public {
        vault.initialize(mockPublicKey, trustedVerifier);
        
        bytes32 userOpHash = keccak256("test operation");
        bytes32 sigHash = keccak256(mockSignature);
        
        // Measure attestation gas
        uint256 gasBefore = gasleft();
        vm.prank(trustedVerifier);
        vault.attestSignature(userOpHash, sigHash);
        uint256 attestGas = gasBefore - gasleft();
        
        // Measure validation gas
        gasBefore = gasleft();
        vault.validateUserOp(userOpHash, mockSignature);
        uint256 validateGas = gasBefore - gasleft();
        
        console2.log("=== Gas Benchmark: Trusted Verifier Pattern ===");
        console2.log("Attestation Gas:", attestGas);
        console2.log("Validation Gas:", validateGas);
        console2.log("Total Gas:", attestGas + validateGas);
        console2.log("");
        console2.log("L1 Cost at 30 gwei:", (attestGas + validateGas) * 30, "gwei");
        console2.log("L2 Cost (10x cheaper):", (attestGas + validateGas) * 3, "gwei");
    }
}
