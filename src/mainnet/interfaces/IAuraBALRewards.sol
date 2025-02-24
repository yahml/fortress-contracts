// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

interface IAuraBALRewards {

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);
    
    function stake(uint256 _amount) external returns (bool);

    function getReward() external returns (bool);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    // event RewardAdded(uint256 reward);
    // event RewardPaid(address indexed user, uint256 reward);
    // event Staked(address indexed user, uint256 amount);
    // event Withdrawn(address indexed user, uint256 amount);

    // function addExtraReward(address _reward) external returns (bool);

    // function clearExtraRewards() external;

    // function currentRewards() external view returns (uint256);

    // function donate(uint256 _amount) external returns (bool);

    // function duration() external view returns (uint256);

    // function extraRewards(uint256) external view returns (address);

    // function extraRewardsLength() external view returns (uint256);

    // function getReward(address _account, bool _claimExtras) external returns (bool);

    // function historicalRewards() external view returns (uint256);

    // function lastTimeRewardApplicable() external view returns (uint256);

    // function lastUpdateTime() external view returns (uint256);

    // function newRewardRatio() external view returns (uint256);

    // function operator() external view returns (address);

    // function periodFinish() external view returns (uint256);

    // function pid() external view returns (uint256);

    // function processIdleRewards() external;

    // function queueNewRewards(uint256 _rewards) external returns (bool);

    // function queuedRewards() external view returns (uint256);

    // function rewardManager() external view returns (address);

    // function rewardPerToken() external view returns (uint256);

    // function rewardPerTokenStored() external view returns (uint256);

    // function rewardRate() external view returns (uint256);

    // function rewardToken() external view returns (address);

    // function rewards(address) external view returns (uint256);

    // function stakeAll() external returns (bool);

    // function stakeFor(address _for, uint256 _amount) external returns (bool);

    // function stakingToken() external view returns (address);

    // function totalSupply() external view returns (uint256);

    // function userRewardPerTokenPaid(address) external view returns (uint256);

    // function withdrawAll(bool claim) external;

    // function withdrawAllAndUnwrap(bool claim) external;

    // function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);
}