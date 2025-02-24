// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

// ███████╗░█████╗░██████╗░████████╗██████╗░███████╗░██████╗░██████╗
// ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██╔════╝██╔════╝
// █████╗░░██║░░██║██████╔╝░░░██║░░░██████╔╝█████╗░░╚█████╗░╚█████╗░
// ██╔══╝░░██║░░██║██╔══██╗░░░██║░░░██╔══██╗██╔══╝░░░╚═══██╗░╚═══██╗
// ██║░░░░░╚█████╔╝██║░░██║░░░██║░░░██║░░██║███████╗██████╔╝██████╔╝
// ╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚═════╝░╚═════╝░
// ███████╗██╗███╗░░██╗░█████╗░███╗░░██╗░█████╗░███████╗
// ██╔════╝██║████╗░██║██╔══██╗████╗░██║██╔══██╗██╔════╝
// █████╗░░██║██╔██╗██║███████║██╔██╗██║██║░░╚═╝█████╗░░
// ██╔══╝░░██║██║╚████║██╔══██║██║╚████║██║░░██╗██╔══╝░░
// ██║░░░░░██║██║░╚███║██║░░██║██║░╚███║╚█████╔╝███████╗
// ╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░╚══════╝
                                                         
//  _____ _     _____                             _         
// |   __| |___|     |___ _____ ___ ___ _ _ ___ _| |___ ___ 
// |  |  | | . |   --| . |     | . | . | | |   | . | -_|  _|
// |_____|_|  _|_____|___|_|_|_|  _|___|___|_|_|___|___|_|  
//         |_|                 |_|                          

// Github - https://github.com/FortressFinance

import "src/shared/compounders/TokenCompounderBase.sol";
import "src/arbitrum/interfaces/IGlpRewardHandler.sol";
import "src/arbitrum/interfaces/IGlpMinter.sol";
import "src/arbitrum/interfaces/IGlpRewardTracker.sol";

contract GlpCompounder is TokenCompounderBase {

    using SafeERC20 for IERC20;

    /// @notice The address of the contract that handles rewards.
    address public rewardHandler;
    /// @notice The address of the contract that trackes ETH rewards.
    address public rewardTracker;
    /// @notice The address of the contract that mints and stakes GLP.
    address public glpHandler;
    /// @notice The address of the contract that needs an approval before minting GLP.
    address public glpManager;

    /// @notice The address of sGLP token.
    address public constant sGLP = 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf;
    /// @notice The address of WETH token.
    address public constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    
    /********************************** Constructor **********************************/
    
    constructor(address _owner, address _platform, address _swap) TokenCompounderBase(ERC20(sGLP), "Fortress GLP", "fortGLP", _owner, _platform, _swap) {
        rewardHandler = 0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1;
        rewardTracker = 0x4e971a87900b931fF39d1Aad67697F49835400b6;
        glpHandler = 0xB95DB5B167D75e6d04227CfFFA61069348d271F5;
        glpManager = 0x3963FfC9dff443c2A94f21b129D429891E32ec18;
    }

    /********************************** View Functions **********************************/

    /// @notice Return the amount of ETH pending rewards (without accounting for other rewards).
    function pendingRewards() public view returns (uint256) {
        return IGlpRewardTracker(rewardTracker).claimable(address(this));
    }

    /// @notice See {TokenCompounderBase - isPendingRewards}
    function isPendingRewards() public view override returns (bool) {
        return (pendingRewards() > 0);
    }

    /********************************** Mutated Functions **********************************/

    /// @notice Extending the base function to enable deposit of any one of GLP's underlying assets.
    function depositUnderlying(address _underlyingAsset, uint256 _underlyingAssets, address _receiver, uint256 _minAmount) public nonReentrant returns (uint256 _shares) {
        if (!(_underlyingAssets > 0)) revert ZeroAmount();

        IERC20(_underlyingAsset).safeTransferFrom(msg.sender, address(this), _underlyingAssets);
        
        address _sGLP = sGLP;
        uint256 _before = IERC20(_sGLP).balanceOf(address(this));
        _approve(_underlyingAsset, glpManager, _underlyingAssets);
        IGlpMinter(glpHandler).mintAndStakeGlp(_underlyingAsset, _underlyingAssets, 0, 0);
        uint256 _assets = IERC20(_sGLP).balanceOf(address(this)) - _before;
        if (!(_assets >= _minAmount)) revert InsufficientAmountOut();

        _shares = previewDeposit(_assets);
        _deposit(msg.sender, _receiver, _assets, _shares);

        return _shares;
    }

    /// @notice Extending the base function to enable withdrawal of any one of GLP's underlying assets.
    function redeemUnderlying(address _underlyingAsset, uint256 _shares, address _receiver, address _owner, uint256 _minAmount) public nonReentrant returns (uint256 _underlyingAssets) {
        if (_shares > maxRedeem(_owner)) revert InsufficientBalance();

        uint256 _assets = previewRedeem(_shares);
        _withdraw(msg.sender, _receiver, _owner, _assets, _shares);

        uint256 _before = IERC20(_underlyingAsset).balanceOf(address(this));
        IGlpMinter(glpHandler).unstakeAndRedeemGlp(_underlyingAsset, _assets, 0, address(this));
        _underlyingAssets = IERC20(_underlyingAsset).balanceOf(address(this)) - _before;
        if (!(_underlyingAssets >= _minAmount)) revert InsufficientAmountOut();

        IERC20(_underlyingAsset).safeTransfer(_receiver, _underlyingAssets);

        return _underlyingAssets;
    }

    /// @notice See {TokenCompounderBase - depositUnderlying}
    function depositUnderlying(uint256 _underlyingAssets, address _receiver, uint256 _minAmount) external override nonReentrant returns (uint256 _shares) {
        return depositUnderlying(WETH, _underlyingAssets, _receiver, _minAmount);
    }

    /// @notice See {TokenCompounderBase - redeemUnderlying}
    function redeemUnderlying(uint256 _shares, address _receiver, address _owner, uint256 _minAmount) public override nonReentrant returns (uint256 _underlyingAssets) {
        return redeemUnderlying(WETH, _shares, _receiver, _owner, _minAmount);
    }

    /********************************** Restricted Functions **********************************/

    function updateGlpContracts(address _rewardHandler, address _rewardsTracker, address _glpHandler, address _glpManager) external {
        if (msg.sender != owner) revert Unauthorized();

        rewardHandler = _rewardHandler;
        rewardTracker = _rewardsTracker;
        glpHandler = _glpHandler;
        glpManager = _glpManager;
    }

    /********************************** Internal Functions **********************************/

    function _customDeposit(uint256 _assets) internal override {}

    function _customWithdraw(uint256 _assets) internal override {}

    function _harvest(address _receiver, uint256 _minBounty) internal override returns (uint256 _rewards) {
        // Claim rewards - compound GMX, esGMX, and MP rewards. Claim ETH rewards as WETH.
        IGlpRewardHandler(rewardHandler).handleRewards(true, true, true, true, true, true, false);

        address _sGLP = sGLP;
        address _weth = WETH;
        uint256 _balance = IERC20(_weth).balanceOf(address(this));
        uint256 _before = IERC20(_sGLP).balanceOf(address(this));
        _approve(_weth, glpManager, _balance);
        IGlpMinter(glpHandler).mintAndStakeGlp(_weth, _balance, 0, 0);
        _rewards = IERC20(_sGLP).balanceOf(address(this)) - _before;
        
        if (_rewards > 0) {
            uint256 _platformFee = platformFeePercentage;
            uint256 _harvestBounty = harvestBountyPercentage;
            if (_platformFee > 0) {
                _platformFee = (_platformFee * _rewards) / FEE_DENOMINATOR;
                _rewards = _rewards - _platformFee;
                IERC20(_sGLP).safeTransfer(platform, _platformFee);
            }
            if (_harvestBounty > 0) {
                _harvestBounty = (_harvestBounty * _rewards) / FEE_DENOMINATOR;
                if (!(_harvestBounty >= _minBounty)) revert InsufficientAmountOut();
                
                _rewards = _rewards - _harvestBounty;
                IERC20(_sGLP).safeTransfer(_receiver, _harvestBounty);
            }
            
            emit Harvest(_receiver, _rewards);
            return _rewards;
        } else {
            revert NoPendingRewards();
        }
    }

    function _approve(address _token, address _spender, uint256 _amount) internal {
        IERC20(_token).safeApprove(_spender, 0);
        IERC20(_token).safeApprove(_spender, _amount);
    }
}