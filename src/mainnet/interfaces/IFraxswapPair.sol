// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IUniswapV2PairV5 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IFraxswapPair is IUniswapV2PairV5 {

    event LongTermSwap0To1(address indexed addr, uint256 orderId, uint256 amount0In, uint256 numberOfTimeIntervals);
    event LongTermSwap1To0(address indexed addr, uint256 orderId, uint256 amount1In, uint256 numberOfTimeIntervals);
    event CancelLongTermOrder(address indexed addr, uint256 orderId, address sellToken, uint256 unsoldAmount, address buyToken, uint256 purchasedAmount);
    event WithdrawProceedsFromLongTermOrder(address indexed addr, uint256 orderId, address indexed proceedToken, uint256 proceeds, bool orderExpired);

    function longTermSwapFrom0To1(uint256 amount0In, uint256 numberOfTimeIntervals) external returns (uint256 orderId);
    function longTermSwapFrom1To0(uint256 amount1In, uint256 numberOfTimeIntervals) external returns (uint256 orderId);
    function cancelLongTermSwap(uint256 orderId) external;
    function withdrawProceedsFromLongTermSwap(uint256 orderId) external returns (bool is_expired, address rewardTkn, uint256 totalReward);
    function executeVirtualOrders(uint256 blockTimestamp) external;

    function orderTimeInterval() external returns (uint256);
    function getTWAPHistoryLength() external view returns (uint);
    function getTwammReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast, uint112 _twammReserve0, uint112 _twammReserve1);
    function getReserveAfterTwamm(uint256 blockTimestamp) external view returns (uint112 _reserve0, uint112 _reserve1, uint256 lastVirtualOrderTimestamp, uint112 _twammReserve0, uint112 _twammReserve1);
    function getNextOrderID() external view returns (uint256);
    function getOrderIDsForUser(address user) external view returns (uint256[] memory);
    function getOrderIDsForUserLength(address user) external view returns (uint256);
    function twammUpToDate() external view returns (bool);
    function getTwammState() external view returns (uint256 token0Rate, uint256 token1Rate, uint256 lastVirtualOrderTimestamp, uint256 orderTimeInterval_rtn, uint256 rewardFactorPool0, uint256 rewardFactorPool1);
    function getTwammSalesRateEnding(uint256 _blockTimestamp) external view returns (uint256 orderPool0SalesRateEnding, uint256 orderPool1SalesRateEnding);
    function getTwammRewardFactor(uint256 _blockTimestamp) external view returns (uint256 rewardFactorPool0AtTimestamp, uint256 rewardFactorPool1AtTimestamp);
    function getTwammOrder(uint256 orderId) external view returns (uint256 id, uint256 expirationTimestamp, uint256 saleRate, address owner, address sellTokenAddr, address buyTokenAddr);
    function getTwammOrderProceedsView(uint256 orderId, uint256 blockTimestamp) external view returns (bool orderExpired, uint256 totalReward);
    function getTwammOrderProceeds(uint256 orderId) external returns (bool orderExpired, uint256 totalReward);


    function togglePauseNewSwaps() external;
}