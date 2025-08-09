// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SmartAccount.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract SmartAccountFactory {
    IEntryPoint public immutable entryPoint;

    constructor(IEntryPoint _entryPoint) {
        entryPoint = _entryPoint;
    }   

    function createAccount(uint256 salt) external returns (SmartAccount account) {
        account = new SmartAccount{salt: bytes32(salt)}(address(entryPoint), msg.sender);
    }

    function getAddress(uint256 salt) external view returns (address predicted) {
        bytes memory code = abi.encodePacked(
            type(SmartAccount).creationCode,
            abi.encode(address(entryPoint), msg.sender)
        );

        bytes32 bytecodeHash = keccak256(code);
        predicted = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            bytes32(salt),
            bytecodeHash
        )))));
    }
}
