// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";

import {TeamManagement} from "./TeamManagement.sol";

/**
 * @notice ETHPool is a contract that allows users to deposit ETH and earn
 *         interest on a weekly basis. New rewards are deposited manually into
 *         the pool by the ETHPool team each week.
 */
contract ETHPool is TeamManagement {
    using Address for address payable;

    struct SnapshotReward {
        uint256 timestamp;
        uint256 amount;
        uint256 lastTotal;
    }

    struct UserDeposit {
        uint256 lastDeposit;
        uint256 lastestTime;
        uint256 total;
    }

    struct Withdrawals {
        uint256 amount;
        uint256 lastWithdrawlTime;
        // (2^16) / 52 = 1,260 years
        uint16 weeklyDepositIndex;
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
    uint16 public nextWeek; // up to: (2^16 weeks) / 52 = 1,260 years

    /*//////////////////////////////////////////////////////////////
                            TRACK USER'S DATA
    //////////////////////////////////////////////////////////////*/
    mapping(address => UserDeposit) public usersDeposits;
    mapping(address => Withdrawals) public usersWithdrawals;
    uint256 public totalUsersDeposits;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event RewardsDeposit(
        uint256 indexed amount,
        uint256 timestamp,
        address indexed user
    );
    event UsersDeposit(address indexed user, uint256 indexed amount);
    event Withdrawl(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed weeklyDepositIndex
    );

    /**
     * @notice Deposit ETH for rewards into the pool.
     * @dev Only ETHPool team can deposit rewards.
     */
    function depositRewards() external payable onlyOwnerOrTeam {
        require(msg.value > 0, "REWARDS_ZERO");

        snapshotRewards.timestamp = block.timestamp;
        snapshotRewards.amount = msg.value;
        snapshotRewards.lastTotal = totalRewards;

        snapshotDeposits = totalUsersDeposits;

        totalRewards += msg.value;
        weeklyRewardsDeposits.push(msg.value);

        ++nextWeek;

        emit RewardsDeposit(msg.value, block.timestamp, msg.sender);
    }

    /**
     * @notice Users deposit ETH into the pool to earn rewards.
     * @dev For calculations simplicity, we authorize users to deposit only
     *      once a week.
     */
    function userDeposit() external payable {
        require(msg.value > 0, "DEPOSIT_ZERO");
        require(
            block.timestamp - usersDeposits[msg.sender].lastestTime >= 1 weeks,
            "DEPOSIT_ONCE_WEEK"
        );

        usersDeposits[msg.sender].lastDeposit = msg.value;
        usersDeposits[msg.sender].lastestTime = block.timestamp;
        usersDeposits[msg.sender].total += msg.value;

        totalUsersDeposits += msg.value;

        emit UsersDeposit(msg.sender, msg.value);
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
    ) public view returns (uint256 pendingRewards) {}

    /**
     * @notice Deposit ETH into the pool.
     * @dev Only ETHPool team can deposit rewards.
     */

    /**
     * @dev Withdraw all rewards.
     * @dev Withdraw only the last 52 weeks, to avoid over gas consumption.
     *         We make the asumption that the user will withdraw funds at the
     *         very least once per year.
     */
    // re-entreency guard / check effects interaction pattern

    /**
     * @notice Withdraw all deposits and rewards simultaneously.
     */
    // re-entreency guard / check effects interaction pattern
}
