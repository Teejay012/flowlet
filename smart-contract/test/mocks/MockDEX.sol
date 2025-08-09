// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockDEX is Ownable {
    struct Pool {
        address tokenA;
        address tokenB;
        uint256 reserveA;
        uint256 reserveB;
        bool exists;
    }
    
    // poolId => Pool
    mapping(bytes32 => Pool) public pools;
    bytes32[] public poolIds;
    
    // Simple price oracle (for testing)
    mapping(address => uint256) public tokenPrices; // Price in ETH (18 decimals)
    
    event PoolCreated(bytes32 indexed poolId, address tokenA, address tokenB, uint256 reserveA, uint256 reserveB);
    event Swap(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event LiquidityAdded(bytes32 indexed poolId, uint256 amountA, uint256 amountB);
    
    constructor() Ownable(msg.sender) {
        // Set some default prices for testing (in ETH)
        tokenPrices[address(0)] = 1e18; // ETH = 1 ETH
    }
    
    /*//////////////////////////////////////////////////////////////
                            POOL MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    
    function createPool(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external onlyOwner {
        require(tokenA != tokenB, "Same tokens");
        require(amountA > 0 && amountB > 0, "Invalid amounts");
        
        // Ensure consistent ordering
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
            (amountA, amountB) = (amountB, amountA);
        }
        
        bytes32 poolId = keccak256(abi.encodePacked(tokenA, tokenB));
        require(!pools[poolId].exists, "Pool exists");
        
        // Transfer tokens to DEX
        if (tokenA == address(0)) {
            require(msg.value >= amountA, "Insufficient ETH");
        } else {
            IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        }
        
        if (tokenB != address(0)) {
            IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        }
        
        pools[poolId] = Pool({
            tokenA: tokenA,
            tokenB: tokenB,
            reserveA: amountA,
            reserveB: amountB,
            exists: true
        });
        
        poolIds.push(poolId);
        
        emit PoolCreated(poolId, tokenA, tokenB, amountA, amountB);
    }
    
    /*//////////////////////////////////////////////////////////////
                            PRICE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function setTokenPrice(address token, uint256 priceInETH) external onlyOwner {
        tokenPrices[token] = priceInETH;
    }
    
    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) public view returns (uint256 amountOut) {
        require(tokenIn != tokenOut, "Same tokens");
        
        bytes32 poolId = getPoolId(tokenIn, tokenOut);
        Pool memory pool = pools[poolId];
        
        if (pool.exists) {
            // Use AMM formula: x * y = k (with 0.3% fee)
            (uint256 reserveIn, uint256 reserveOut) = getReserves(tokenIn, tokenOut, pool);
            
            // Apply 0.3% fee
            uint256 amountInWithFee = amountIn * 997;
            uint256 numerator = amountInWithFee * reserveOut;
            uint256 denominator = (reserveIn * 1000) + amountInWithFee;
            amountOut = numerator / denominator;
        } else {
            // Use simple price oracle
            uint256 priceIn = tokenPrices[tokenIn];
            uint256 priceOut = tokenPrices[tokenOut];
            require(priceIn > 0 && priceOut > 0, "Price not set");
            
            amountOut = (amountIn * priceIn) / priceOut;
        }
    }
    
    /*//////////////////////////////////////////////////////////////
                            SWAP FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts) {
        require(deadline >= block.timestamp, "Expired");
        require(path.length >= 2, "Invalid path");
        
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        
        // For simplicity, only support direct swaps (path length = 2)
        require(path.length == 2, "Multi-hop not supported");
        
        address tokenIn = path[0];
        address tokenOut = path[1];
        
        uint256 amountOut = getAmountOut(amountIn, tokenIn, tokenOut);
        require(amountOut >= amountOutMin, "Insufficient output amount");
        
        amounts[1] = amountOut;
        
        // Transfer tokens in
        if (tokenIn == address(0)) {
            require(msg.value >= amountIn, "Insufficient ETH");
        } else {
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        }
        
        // Update reserves if pool exists
        bytes32 poolId = getPoolId(tokenIn, tokenOut);
        if (pools[poolId].exists) {
            updateReservesAfterSwap(poolId, tokenIn, tokenOut, amountIn, amountOut);
        }
        
        // Transfer tokens out
        if (tokenOut == address(0)) {
            payable(to).transfer(amountOut);
        } else {
            IERC20(tokenOut).transfer(to, amountOut);
        }
        
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }
    
    // Simpler swap function
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) external payable returns (uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        
        uint256[] memory amounts = swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 300
        );
        
        return amounts[1];
    }
    
    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function getPoolId(address tokenA, address tokenB) public pure returns (bytes32) {
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }
        return keccak256(abi.encodePacked(tokenA, tokenB));
    }
    
    function getReserves(
        address tokenIn,
        address tokenOut,
        Pool memory pool
    ) internal pure returns (uint256 reserveIn, uint256 reserveOut) {
        if (tokenIn == pool.tokenA) {
            (reserveIn, reserveOut) = (pool.reserveA, pool.reserveB);
        } else {
            (reserveIn, reserveOut) = (pool.reserveB, pool.reserveA);
        }
    }
    
    function updateReservesAfterSwap(
        bytes32 poolId,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    ) internal {
        Pool storage pool = pools[poolId];
        
        if (tokenIn == pool.tokenA) {
            pool.reserveA += amountIn;
            pool.reserveB -= amountOut;
        } else {
            pool.reserveB += amountIn;
            pool.reserveA -= amountOut;
        }
    }
    
    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/
    
    function getPool(bytes32 poolId) external view returns (Pool memory) {
        return pools[poolId];
    }
    
    function getAllPools() external view returns (bytes32[] memory) {
        return poolIds;
    }
    
    function getPoolByTokens(address tokenA, address tokenB) external view returns (Pool memory) {
        bytes32 poolId = getPoolId(tokenA, tokenB);
        return pools[poolId];
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
    
    // Add liquidity to existing pool
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external payable onlyOwner {
        bytes32 poolId = getPoolId(tokenA, tokenB);
        require(pools[poolId].exists, "Pool doesn't exist");
        
        // Transfer tokens  
        if (tokenA == address(0)) {
            require(msg.value >= amountA, "Insufficient ETH");
        } else {
            IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        }
        
        if (tokenB != address(0)) {
            IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        }
        
        // Update reserves
        Pool storage pool = pools[poolId];
        if (tokenA == pool.tokenA) {
            pool.reserveA += amountA;
            pool.reserveB += amountB;
        } else {
            pool.reserveA += amountB;
            pool.reserveB += amountA;
        }
        
        emit LiquidityAdded(poolId, amountA, amountB);
    }
    
    receive() external payable {}
}