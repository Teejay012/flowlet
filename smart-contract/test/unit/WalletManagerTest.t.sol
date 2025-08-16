// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import {Test} from "forge-std/Test.sol";
// import {MockDEX} from "test/mocks/MockDEX.sol";
// import {WalletManager} from "src/WalletManager.sol";
// import {SmartAccount} from "src/SmartAccount.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
// import {SmartAccountFactory} from "../../src/SmartAccountFactory.sol";
// import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
// import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

// contract WalletManagerTest is Test {
//     MockDEX public dex;
//     WalletManager public walletManager;
//     SmartAccount public account;
//     ERC20Mock public tokenA;
//     ERC20Mock public tokenB;

//     function setUp() public {
//         entryPoint = new EntryPoint();
//         account = new SmartAccount(address(entryPoint), user.addr);
//         token = new ERC20Mock();
//         usdc = new ERC20Mock();
//         paymaster = new USDCPaymaster(address(entryPoint), address(usdc), address(account));
//         walletManager = account.walletManager();

//         deal(address(usdc), address(account), 1000 * 1e6); // 1000 USDC
//         deal(address(token), address(account), 1000 * 1e18); // 1000 Tokens
//     }
// }