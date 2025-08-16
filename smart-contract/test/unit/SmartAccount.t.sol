// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import {Test, console2} from "forge-std/Test.sol";
// import {SmartAccount} from "../../src/SmartAccount.sol";
// import {USDCPaymaster} from "../../src/USDCPaymaster.sol";
// import {SmartAccountFactory} from "../../src/SmartAccountFactory.sol";
// import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
// import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
// import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
// import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
// import {IPaymaster} from "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// contract SmartAccountTest is Test {
//     using MessageHashUtils for bytes32;

//     SmartAccount public account;
//     USDCPaymaster public paymaster;
//     EntryPoint public entryPoint;
//     ERC20Mock token;
//     ERC20Mock usdc;

//     Account user = makeAccount("user");
//     address random = makeAddr("random");

//     function setUp() public {
//         entryPoint = new EntryPoint();
//         account = new SmartAccount(address(entryPoint), user.addr);
//         token = new ERC20Mock();
//         usdc = new ERC20Mock();
//         paymaster = new USDCPaymaster(address(entryPoint), address(usdc), address(account));

//         deal(address(usdc), address(account), 1000 * 1e6); // 1000 USDC
//         deal(address(token), address(account), 1000 * 1e18); // 1000 Tokens

//         // vm.prank(address(account));
//         // usdc.approve(address(paymaster), type(uint256).max); // Approve paymaster to spend USDC
//     }

//     function testOwnerCanExecuteCommands() public {
//         assertEq(account.owner(), user.addr);
//         assertEq(token.balanceOf(address(account)), 0);
//         uint256 value = 0;
//         address dest = address(token);
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", user.addr, 1000);

//         vm.startPrank(user.addr);
//         account.execute(dest, value, data);
//         vm.stopPrank();

//         assertEq(token.balanceOf(user.addr), 1000, "Owner should be able to execute commands");
//     }

//     function testNonOwnerCannotExecuteCommands() public {
//         assertEq(account.owner(), user.addr);
//         assertEq(token.balanceOf(address(account)), 0);
//         uint256 value = 0;
//         address dest = address(token);
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", user.addr, 1000);

//         vm.startPrank(random);
//         vm.expectRevert(SmartAccount.MultisigSmartAccount__NotFromEntryPointOrOwner.selector);
//         account.execute(dest, value, data);
//         vm.stopPrank();
//     }

//     function testRecoverSignedOp() public {
//         // address sender;
//         // uint256 nonce;
//         // bytes initCode;
//         // bytes callData;
//         // bytes32 accountGasLimits;
//         // uint256 preVerificationGas;
//         // bytes32 gasFees;
//         // bytes paymasterAndData;
//         // bytes signature;

//         uint256 value = 0;
//         address dest = address(token);
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", user.addr, 1000);

//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);


//         uint128 verificationGasLimit = 16777216;
//         uint128 callGasLimit = verificationGasLimit;
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         uint256 nonce = vm.getNonce(address(account)) - 1;

//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: hex"",
//             signature: hex""
//         });

//         bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);
//         // bytes32 digest = userOpHash.toEthSignedMessageHash();

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.key, userOpHash);
//         userOp.signature = abi.encodePacked(r, s, v);

//         bytes32 updatedUserOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);

//         address actualSigner = ECDSA.recover(updatedUserOpHash, userOp.signature);

//         assertEq(actualSigner, user.addr);
//     }

//     function testValidationOfUserOps() public {
//         uint256 value = 0;
//         address dest = address(token);
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", user.addr, 1000);

//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);


//         uint128 verificationGasLimit = 16777216;
//         uint128 callGasLimit = verificationGasLimit;
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         uint256 nonce = vm.getNonce(address(account)) - 1;

//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: hex"",
//             signature: hex""
//         });

//         bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.key, userOpHash);
//         userOp.signature = abi.encodePacked(r, s, v);
//         uint256 missingAccountFunds = 1e18;
        
//         vm.prank(address(entryPoint));
//         uint256 valaidationData = account.validateUserOp(userOp, userOpHash, missingAccountFunds);

//         assertEq(valaidationData, 0);

//     }

//     function testEntryPointCanExecuteCommands() public {
//         uint256 value = 0;
//         address dest = address(token);
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", address(account), 1000);

//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);


//         uint128 verificationGasLimit = 16777216;
//         uint128 callGasLimit = verificationGasLimit;
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         uint256 nonce = vm.getNonce(address(account)) - 1;

//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: hex"",
//             signature: hex""
//         });

//         bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.key, userOpHash);
//         userOp.signature = abi.encodePacked(r, s, v);

//         PackedUserOperation[] memory ops = new PackedUserOperation[](1);
//         ops[0] = userOp;

//         vm.deal(address(account), 1e18);

//         uint256 accountBal = token.balanceOf(address(account));

//         vm.prank(random);
//         IEntryPoint(entryPoint).handleOps(ops, payable(random));

//         assertEq(token.balanceOf(address(account)), accountBal + 1000, "EntryPoint should be able to execute commands on behalf of the owner");
//     }






//     function testRevertsWithoutUSDCOrApproval() public {
//         uint256 value = 0;
//         address dest = address(token);

//         // Attempt to mint 1000 tokens from SmartAccount
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", address(account), 1000);

//         // Prepare call to account.execute(dest, value, data)
//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);

//         // Gas settings
//         uint128 verificationGasLimit = 16_777_216;
//         uint128 callGasLimit = verificationGasLimit;
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         // Nonce must match smart account's internal nonce
//         uint256 nonce = account.s_nonce(); // or 0 if you prefer

//         // Construct the PackedUserOperation
//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: hex"", // okay for direct call test
//             signature: hex""
//         });

//         // Expect revert due to lack of approval or balance
//         vm.prank(address(entryPoint));
//         vm.expectRevert(); // optionally: vm.expectRevert(bytes("USDC approval too low"));
//         paymaster.validatePaymasterUserOp(userOp, keccak256("dummyHash"), 1e6);
//     }

//     function testPaymasterValidationPasses() public {
//         uint256 value = 0;
//         address dest = address(token);

//         // Attempt to mint 1000 tokens from SmartAccount
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", address(account), 1000);

//         // Prepare call to account.execute(dest, value, data)
//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);

//         // Gas settings
//         uint128 verificationGasLimit = 16_777_216;
//         uint128 callGasLimit = verificationGasLimit;
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         // Nonce must match smart account's internal nonce
//         uint256 nonce = account.s_nonce(); // or 0 if you prefer

//         // Construct the PackedUserOperation
//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: abi.encodePacked(address(paymaster)), // ✅ FIXED
//             signature: hex""
//         });

//         vm.prank(address(account));
//         usdc.approve(address(paymaster), 1_000e6);

//         vm.prank(address(entryPoint));

//         (bytes memory context, uint256 validationData) = paymaster.validatePaymasterUserOp(
//             userOp,
//             keccak256("dummyHash"),
//             1e6
//         );

//         console2.logBytes(context);
//         console2.log("Validation Data:", validationData);

//         (address decodedSender) = abi.decode(context, (address));
//         console2.log("Decoded sender:", decodedSender);
//         assertEq(validationData, 0, "Validation should succeed");
//         assertEq(decodedSender, address(account));
//     }

//     function testPostOpChargesCorrectUSDC() public {
//         uint256 value = 0;
//         address dest = address(token);

//         // Attempt to mint 1000 tokens from SmartAccount
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", address(account), 1000);

//         // Prepare call to account.execute(dest, value, data)
//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);

//         // Gas settings
//         uint128 verificationGasLimit = 16_777_216;
//         uint128 callGasLimit = verificationGasLimit;
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         // Nonce must match smart account's internal nonce
//         uint256 nonce = account.s_nonce(); // or 0 if you prefer

//         // Construct the PackedUserOperation
//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: abi.encodePacked(address(paymaster)), // ✅ FIXED
//             signature: hex""
//         });

//         bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.key, userOpHash);
//         userOp.signature = abi.encodePacked(r, s, v);

//         vm.prank(address(account));
//         usdc.approve(address(paymaster), 1_000e6);

//         uint256 usdcBefore = usdc.balanceOf(address(account));

//         // Simulate validatePaymasterUserOp
//         vm.prank(address(entryPoint));
//         (bytes memory context,) = paymaster.validatePaymasterUserOp(
//             userOp,
//             keccak256("dummyHash"),
//             1e6
//         );

//         // Simulate gas usage — actualGasCost in wei
//         uint256 gasUsed = 0.01 ether;

//         // Call postOp
//         vm.prank(address(entryPoint));
//         paymaster.postOp(IPaymaster.PostOpMode.opSucceeded, context, gasUsed, gasUsed);

//         uint256 usdcAfter = usdc.balanceOf(address(account));
//         uint256 charged = usdcBefore - usdcAfter;

//         assertGt(charged, 0, "User should be charged some USDC");
//     }

//     // function getSampleUserOp() internal view returns (PackedUserOperation memory) {
//     //     address dest = address(token);
//     //     bytes memory data = abi.encodeWithSignature("mint(address,uint256)", user.addr, 1000);
//     //     bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, 0, data);

//     //     return PackedUserOperation({
//     //         sender: address(account),
//     //         nonce: account.s_nonce(),
//     //         initCode: hex"",
//     //         callData: callData,
//     //         accountGasLimits: bytes32(uint256(200_000) << 128 | 200_000),
//     //         preVerificationGas: 50_000,
//     //         gasFees: bytes32(uint256(1e9) << 128 | 1e9),
//     //         paymasterAndData: abi.encodePacked(address(paymaster)), // simulate bundler including this
//     //         signature: hex""
//     //     });
//     // }


//     function testSmartWalletTx() public {
//         vm.deal(address(paymaster), 1000e18); // Fund paymaster
//         vm.prank(address(paymaster));
//         IEntryPoint(entryPoint).depositTo{value: 1e18}(address(paymaster));

//         uint256 value = 0;
//         address dest = address(token);
//         bytes memory data = abi.encodeWithSignature("mint(address,uint256)", address(account), 1000);
//         bytes memory callData = abi.encodeWithSelector(account.execute.selector, dest, value, data);

//         // Updated gas limits
//         uint256 verificationGasLimit = 200e6;
//         uint256 postOpGasLimit = 200e6;
//         uint128 callGasLimit = uint128(verificationGasLimit);
//         uint128 maxPriorityFeePerGas = 256;
//         uint128 maxFeePerGas = maxPriorityFeePerGas;

//         uint256 nonce = vm.getNonce(address(account)) - 1;

//         uint256 requiredUSDC = 1e6;
//         vm.prank(address(account));
//         usdc.approve(address(paymaster), type(uint256).max); // Approve paymaster to spend USDC

//         // 💡 New format for paymasterAndData
//         bytes memory paymasterAndData = abi.encodePacked(
//             address(paymaster),
//             uint256(verificationGasLimit),
//             uint256(postOpGasLimit)
//         );

//         PackedUserOperation memory userOp = PackedUserOperation({
//             sender: address(account),
//             nonce: nonce,
//             initCode: hex"",
//             callData: callData,
//             accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
//             preVerificationGas: verificationGasLimit,
//             gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
//             paymasterAndData: paymasterAndData,
//             signature: hex""
//         });

//         bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(userOp);
//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.key, userOpHash);
//         userOp.signature = abi.encodePacked(r, s, v);

//         PackedUserOperation[] memory ops = new PackedUserOperation[](1);
//         ops[0] = userOp;

//         vm.deal(address(account), 1e18);

//         uint256 accountBalBefore = token.balanceOf(address(account));
//         uint256 usdcBalBefore = usdc.balanceOf(address(account));

//         vm.prank(random);
//         IEntryPoint(entryPoint).handleOps(ops, payable(random));

//         assertEq(
//             token.balanceOf(address(account)),
//             accountBalBefore + 1000,
//             "Token minting failed"
//         );

//         assertLt(
//             usdc.balanceOf(address(account)),
//             usdcBalBefore,
//             "USDC was not deducted for gas costs"
//         );
//     }



// }