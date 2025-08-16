// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SmartAccountFactory} from "../../src/SmartAccountFactory.sol";
import {SmartAccount} from "../../src/SmartAccount.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract SmartAccountFactoryTest is Test {
    SmartAccountFactory public factory;
    EntryPoint public entryPoint;

    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    function setUp() public {
        entryPoint = new EntryPoint();
        factory = new SmartAccountFactory(IEntryPoint(entryPoint));
    }

    function testCreateAccount() public {
        uint256 salt = 1;
        vm.startPrank(user);
        SmartAccount account = factory.createAccount(user, salt);
        assertEq(address(account), factory.getAddress(user, salt));
        assertEq(account.owner(), user);
        vm.stopPrank();

        vm.startPrank(user2);
        SmartAccount account2 = factory.createAccount(user, salt);
        assertEq(address(account2), factory.getAddress(user, salt));
        assert(account.owner() != account2.owner());
        vm.stopPrank();
    }

    // function testGetAddress() public {
    //     uint256 salt = 2;

    //     address predictedAddress = factory.getAddress(owner, salt);
    //     assertTrue(predictedAddress != address(0));
    // }

    function testFactoryAddressNotEqualToSmartAccoutAddress() public {
        uint256 salt = 3;
        vm.startPrank(user);
        SmartAccount account = factory.createAccount(user, salt);
        assertTrue(address(factory) != address(account));
        vm.stopPrank();
    }
}