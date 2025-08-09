// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockDEX} from "test/mocks/MockDEX.sol";
import {WalletManager} from "src/WalletManager.sol";
import {SmartAccount} from "src/SmartAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DEXTest is Test {
    MockDEX public dex;
    WalletManager public walletManager;
    SmartAccount public smartAccount;
    ERC20Mock public tokenA;
    ERC20Mock public tokenB;
    
    address public owner = address(0x1);
    address public user = address(0x2);
    
    function setUp() public {
        // Deploy contracts
        vm.startPrank(owner);
        
        dex = new MockDEX();
        walletManager = new WalletManager();
        smartAccount = new SmartAccount(address(0), owner); // No EntryPoint for this test
        
        // Deploy mock tokens
        tokenA = new ERC20Mock();
        tokenB = new ERC20Mock();
        
        // Mint tokens for testing
        tokenA.mint(owner, 1000000e18);
        tokenB.mint(owner, 1000000e18);
        tokenA.mint(address(smartAccount), 10000e18);
        tokenB.mint(address(smartAccount), 10000e18);
        
        // Set up token prices in DEX (tokenA = 1 ETH, tokenB = 2 ETH)
        dex.setTokenPrice(address(tokenA), 1e18);
        dex.setTokenPrice(address(tokenB), 2e18);
        
        // Add tokens to WalletManager
        walletManager.addToken(address(tokenA), "Token A", "TKA", 18, true);
        walletManager.addToken(address(tokenB), "Token B", "TKB", 18, true);
        
        // Approve DEX in WalletManager
        walletManager.approveDEX(address(dex));
        
        vm.stopPrank();
    }
    
    function testDirectDEXSwap() public {
        vm.startPrank(owner);
        
        // Approve DEX to spend tokens
        tokenA.approve(address(dex), 1000e18);
        
        uint256 amountIn = 1000e18;
        uint256 expectedAmountOut = dex.getAmountOut(amountIn, address(tokenA), address(tokenB));
        
        uint256 balanceABefore = tokenA.balanceOf(owner);
        uint256 balanceBBefore = tokenB.balanceOf(owner);
        
        // Perform swap
        dex.swap(address(tokenA), address(tokenB), amountIn, expectedAmountOut);
        
        uint256 balanceAAfter = tokenA.balanceOf(owner);
        uint256 balanceBAfter = tokenB.balanceOf(owner);
        
        assertEq(balanceABefore - balanceAAfter, amountIn, "TokenA balance should decrease");
        assertEq(balanceBAfter - balanceBBefore, expectedAmountOut, "TokenB balance should increase");
        
        vm.stopPrank();
    }
    
    function testWalletManagerSwap() public {
        vm.startPrank(address(smartAccount));
        
        // SmartAccount approves WalletManager to spend its tokens
        tokenA.approve(address(walletManager), type(uint256).max);
        tokenB.approve(address(walletManager), type(uint256).max);
        
        uint256 amountIn = 1000e18;
        uint256 minAmountOut = dex.getAmountOut(amountIn, address(tokenA), address(tokenB));
        
        // Prepare swap data for DEX
        bytes memory swapData = abi.encodeWithSelector(
            MockDEX.swap.selector,
            address(tokenA),      // tokenIn
            address(tokenB),      // tokenOut
            amountIn,             // amountIn
            minAmountOut          // minAmountOut
        );
        
        WalletManager.SwapParams memory params = WalletManager.SwapParams({
            tokenIn: address(tokenA),
            tokenOut: address(tokenB),
            amountIn: amountIn,
            minAmountOut: minAmountOut,
            dexRouter: address(dex),
            swapData: swapData
        });
        
        uint256 balanceABefore = tokenA.balanceOf(address(smartAccount));
        uint256 balanceBBefore = tokenB.balanceOf(address(smartAccount));
        
        // Execute swap through WalletManager
        walletManager.swapTokens(params);
        
        uint256 balanceAAfter = tokenA.balanceOf(address(smartAccount));
        uint256 balanceBAfter = tokenB.balanceOf(address(smartAccount));
        
        assertEq(balanceABefore - balanceAAfter, amountIn, "TokenA should decrease");
        assertGt(balanceBAfter, balanceBBefore, "TokenB should increase");
        
        vm.stopPrank();
    }
    
    function testCreatePoolAndSwap() public {
        vm.startPrank(owner);
        
        // Create a liquidity pool
        uint256 liquidityA = 10000e18;
        uint256 liquidityB = 5000e18; // 2:1 ratio
        
        tokenA.approve(address(dex), liquidityA);
        tokenB.approve(address(dex), liquidityB);
        
        dex.createPool(address(tokenA), address(tokenB), liquidityA, liquidityB);
        
        vm.stopPrank();
        
        // Now test swap using the pool
        vm.startPrank(address(smartAccount));
        
        tokenA.approve(address(walletManager), type(uint256).max);
        
        uint256 amountIn = 100e18;
        uint256 minAmountOut = dex.getAmountOut(amountIn, address(tokenA), address(tokenB));
        
        bytes memory swapData = abi.encodeWithSelector(
            MockDEX.swap.selector,
            address(tokenA),
            address(tokenB),
            amountIn,
            minAmountOut * 95 / 100 // 5% slippage tolerance
        );
        
        WalletManager.SwapParams memory params = WalletManager.SwapParams({
            tokenIn: address(tokenA),
            tokenOut: address(tokenB),
            amountIn: amountIn,
            minAmountOut: minAmountOut * 95 / 100,
            dexRouter: address(dex),
            swapData: swapData
        });
        
        uint256 balanceBBefore = tokenB.balanceOf(address(smartAccount));
        
        walletManager.swapTokens(params);
        
        uint256 balanceBAfter = tokenB.balanceOf(address(smartAccount));
        uint256 actualAmountOut = balanceBAfter - balanceBBefore;
        
        assertGt(actualAmountOut, 0, "Should receive tokens");
        assertGe(actualAmountOut, minAmountOut * 95 / 100, "Should meet minimum output");
        
        vm.stopPrank();
    }
    
    function testGetAmountOut() public view {
        uint256 amountIn = 1000e18;
        uint256 amountOut = dex.getAmountOut(amountIn, address(tokenA), address(tokenB));
        
        // With price oracle: tokenA = 1 ETH, tokenB = 2 ETH
        // Expected: 1000 * 1 / 2 = 500 tokenB
        assertEq(amountOut, 500e18, "Amount out should be 500 tokenB");
    }
}