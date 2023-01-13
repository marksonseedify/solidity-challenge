// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";

abstract contract UserData {
    using Address for address payable;

    struct UserDeposit {
        uint256 lastDeposit;
        uint256 lastestTime;
        uint256 total;
        // uint16 depositWeekIndex;
    }

    struct UserWithdrawal {
        // (2^16) / 52 = 1,260 years
        uint16 withdrawWeekIndex;
        uint256 amount;
        uint256 lastWithdrawTime;
    }

    /*//////////////////////////////////////////////////////////////
                            TRACK USER'S DATA
    //////////////////////////////////////////////////////////////*/
    mapping(address => UserDeposit) public usersDeposits;
    mapping(address => UserWithdrawal) public usersWithdrawals;
    uint256 public totalUsersDeposits;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event UsersDeposit(address indexed user, uint256 indexed amount);
    event Withdrawl(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed withdrawWeekIndex
    );

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
     * @notice Withdraw pending rewards.
     * @dev For calculations simplicity, we authorize users to withdraw only
     *      once a week.
     */
    function _withdrawPendingRewards(uint256 rewards, uint16 week) internal {
        require(rewards > 0, "NO_REWARDS_FOR_USER");
        require(
            block.timestamp - usersWithdrawals[msg.sender].lastWithdrawTime >=
                1 weeks,
            "WITHDRAW_ONCE_WEEK"
        );

        // check effects interaction pattern
        usersWithdrawals[msg.sender].withdrawWeekIndex = week;
        usersWithdrawals[msg.sender].amount = rewards;
        usersWithdrawals[msg.sender].lastWithdrawTime = block.timestamp;

        payable(msg.sender).sendValue(rewards);

        emit Withdrawl(msg.sender, rewards, week);
    }

    /**
     * @notice Withdraw all deposits and rewards simultaneously.
     */
    // re-entreency guard / check effects interaction pattern
}
