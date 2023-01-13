// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract Rewards {
    struct SnapshotReward {
        uint256 timestamp;
        uint256 amount;
        uint256 previousTotal;
    }

    /*//////////////////////////////////////////////////////////////
                            ETHPool TEAM
    //////////////////////////////////////////////////////////////*/
    uint256[] public weeklyRewardsDeposits;
    uint256 public totalRewards;

    /*//////////////////////////////////////////////////////////////
                            SNAPSHOT
    //////////////////////////////////////////////////////////////*/
    // all used on weekly rewards deposits
    SnapshotReward public snapshotRewards;
    uint256 public snapshotDeposits;
    uint16 public nextDepositWeek; // up to: (2^16 weeks) / 52 = 1,260 years

    event RewardsDeposit(
        uint256 indexed amount,
        uint256 timestamp,
        address indexed user
    );

    /**
     * @notice Deposit ETH for rewards into the pool.
     * @dev Only ETHPool team can deposit rewards.
     */
    function _depositRewards() internal {
        require(msg.value > 0, "REWARDS_ZERO");

        snapshotRewards.timestamp = block.timestamp;
        snapshotRewards.amount = msg.value;
        snapshotRewards.previousTotal = totalRewards;

        totalRewards += msg.value;
        weeklyRewardsDeposits.push(msg.value);

        ++nextDepositWeek;

        emit RewardsDeposit(msg.value, block.timestamp, msg.sender);
    }

    /**
      * @notice Compute the pending rewards for a user taking into account:
      *         - if they deposited before the last team weekly deposit
                  timestamp 
                - how much shares they have in the pool based on what they
                  deposited
      */
    function pendingRewards(
        address user
    ) external view virtual returns (uint256 rewards);
}
