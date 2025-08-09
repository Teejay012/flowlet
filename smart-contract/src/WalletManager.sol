// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletManager is Ownable {
    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
        bool isActive;
        bool isVerified;
    }
    
    struct SwapParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        address dexRouter;
        bytes swapData;
    }
    
    mapping(address => TokenInfo) public tokens;
    address[] public tokenList;
    mapping(address => bool) public approvedDEXs;
    
    event TokenAdded(address indexed token, string name, string symbol);
    event TokenSwapped(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    
    constructor() Ownable(msg.sender) {}
    
    /*//////////////////////////////////////////////////////////////
                            TOKEN MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    
    function addToken(
        address token,
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        bool isVerified
    ) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(!tokens[token].isActive, "Token already exists");
        
        tokens[token] = TokenInfo({
            name: name,
            symbol: symbol,
            decimals: decimals,
            isActive: true,
            isVerified: isVerified
        });
        
        tokenList.push(token);
        emit TokenAdded(token, name, symbol);
    }
    
    function removeToken(address token) external onlyOwner {
        require(tokens[token].isActive, "Token not active");
        tokens[token].isActive = false;
        
        // Remove from tokenList array
        for (uint i = 0; i < tokenList.length; i++) {
            if (tokenList[i] == token) {
                tokenList[i] = tokenList[tokenList.length - 1];
                tokenList.pop();
                break;
            }
        }
    }
    
    /*//////////////////////////////////////////////////////////////
                            WALLET OPERATIONS
    //////////////////////////////////////////////////////////////*/
    
    function transferToken(
        address token,
        address to,
        uint256 amount
    ) external {
        require(tokens[token].isActive || token == address(0), "Token not supported");
        
        if (token == address(0)) {
            // ETH transfer
            (bool success,) = payable(to).call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            // ERC20 transfer
            IERC20(token).transfer(to, amount);
        }
    }
    
    function batchTransfer(
        address[] calldata tokens_,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(tokens_.length == recipients.length && recipients.length == amounts.length, "Array length mismatch");
        
        for (uint i = 0; i < tokens_.length; i++) {
            transferToken(tokens_[i], recipients[i], amounts[i]);
        }
    }
    
    /*//////////////////////////////////////////////////////////////
                                SWAPPING
    //////////////////////////////////////////////////////////////*/
    
    function approveEX(address dex) external onlyOwner {
        approvedDEXs[dex] = true;
    }
    
    function swapTokens(SwapParams calldata params) external {
        require(approvedDEXs[params.dexRouter], "DEX not approved");
        require(tokens[params.tokenIn].isActive, "Input token not supported");
        require(tokens[params.tokenOut].isActive, "Output token not supported");
        
        // Transfer tokens from user to this contract
        IERC20(params.tokenIn).transferFrom(msg.sender, address(this), params.amountIn);
        
        // Approve DEX to spend tokens
        IERC20(params.tokenIn).approve(params.dexRouter, params.amountIn);
        
        uint256 balanceBefore = IERC20(params.tokenOut).balanceOf(address(this));
        
        // Execute swap through DEX router
        (bool success,) = params.dexRouter.call(params.swapData);
        require(success, "Swap failed");
        
        uint256 balanceAfter = IERC20(params.tokenOut).balanceOf(address(this));
        uint256 amountOut = balanceAfter - balanceBefore;
        
        require(amountOut >= params.minAmountOut, "Insufficient output amount");
        
        // Transfer output tokens to user
        IERC20(params.tokenOut).transfer(msg.sender, amountOut);
        
        emit TokenSwapped(msg.sender, params.tokenIn, params.tokenOut, params.amountIn, amountOut);
    }
    
    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/
    
    function getTokenList() external view returns (address[] memory) {
        return tokenList;
    }
    
    function getActiveTokens() external view returns (address[] memory activeTokens) {
        uint256 activeCount = 0;
        
        // Count active tokens
        for (uint i = 0; i < tokenList.length; i++) {
            if (tokens[tokenList[i]].isActive) {
                activeCount++;
            }
        }
        
        // Create array of active tokens
        activeTokens = new address[](activeCount);
        uint256 index = 0;
        
        for (uint i = 0; i < tokenList.length; i++) {
            if (tokens[tokenList[i]].isActive) {
                activeTokens[index] = tokenList[i];
                index++;
            }
        }
    }
    
    function getTokenBalance(address token, address user) external view returns (uint256) {
        if (token == address(0)) {
            return user.balance;
        }
        return IERC20(token).balanceOf(user);
    }
    
    function getTokenInfo(address token) external view returns (TokenInfo memory) {
        return tokens[token];
    }
    
    /*//////////////////////////////////////////////////////////////
                            EMERGENCY FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }
    
    receive() external payable {}
}