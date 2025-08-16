// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {SmartAccountFactory} from "src/SmartAccountFactory.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract DeploySmartAccount is Script {
        address entryPoint = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789; 
    function run() external returns (SmartAccountFactory) {
        vm.startBroadcast();

        SmartAccountFactory factory = new SmartAccountFactory(IEntryPoint(entryPoint));

        vm.stopBroadcast();
        console2.log("SmartAccountFactory deployed at:", address(factory));
        return factory;
    }
}

// 0x8F08a3eEBFeAe1b6a933925Caa16B511Ee9Ed848