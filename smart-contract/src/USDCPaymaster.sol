// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPaymaster} from "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract USDCPaymaster is IPaymaster, Ownable {
    IEntryPoint public immutable entryPoint;
    IERC20 public immutable usdc;
    address public smartAccountImplementation;

    constructor(
        address _entryPoint,
        address _usdc,
        address _smartAccountImplementation
    ) Ownable(msg.sender) {
        entryPoint = IEntryPoint(_entryPoint);
        usdc = IERC20(_usdc);
        smartAccountImplementation = _smartAccountImplementation;
    }

    modifier onlyEntryPoint() {
        require(msg.sender == address(entryPoint), "Not from EntryPoint");
        _;
    }

    /**
     * Validate whether the Paymaster will sponsor the transaction.
     */
    function validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 /* maxCost */
    ) external override onlyEntryPoint returns (bytes memory context, uint256 validationData) {
        // decode sender and assume sender is SmartAccount (or clone of it)
        address sender = userOp.sender;

        // require USDC approval
        uint256 requiredPreCharge = 1e6; // Assume flat 1 USDC for now (with 6 decimals)
        require(usdc.allowance(sender, address(this)) >= requiredPreCharge, "USDC approval too low");
        require(usdc.balanceOf(sender) >= requiredPreCharge, "Insufficient USDC balance");

        // Store context for use in postOp (encoded sender)
        context = abi.encode(sender);

        // 0 validationData means "valid forever, sig valid"
        validationData = 0;
    }

    /**
     * Deduct USDC from sender after successful or reverted execution.
     */
    function postOp(
        PostOpMode /* mode */,
        bytes calldata context,
        uint256 /* actualGasCost */,
        uint256 /* actualUserOpFeePerGas */
    ) external override onlyEntryPoint {
        address sender = abi.decode(context, (address));
        uint256 charge = 1e6; // flat charge for now
        require(usdc.transferFrom(sender, address(this), charge), "USDC transfer failed");
    }

    /**
     * Allow owner to withdraw collected USDC
     */
    function withdrawUSDC(address to, uint256 amount) external onlyOwner {
        require(usdc.transfer(to, amount), "Withdraw failed");
    }

    receive() external payable {}
}
