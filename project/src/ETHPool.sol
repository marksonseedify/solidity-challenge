// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";

/**
 * @notice ETHPool is a contract that allows users to deposit ETH and earn
 *         interest on a weekly basis. New rewards are deposited manually into
 *         the pool by the ETHPool team each week.
 */
contract ETHPool {
    struct Withdrawals {
        uint256 amount;
        uint256 lastWithdrawlTime;
        // (2^16) / 52 = 1,260 years
        uint16 weeklyDepositIndex;
    }

    mapping(address => uint256) public usersDeposits;
    mapping(address => Withdrawals) public usersWithdrawals;

    uint256[] public weeklyRewardsDeposits;
    uint256 public totalRewardsDeposited;

    event TeamMemberAdded(address indexed teamMember);
    event TeamMemberRemoved(address indexed teamMember);

    event Deposit(address indexed user, uint256 indexed amount);
    event Withdrawl(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed weeklyDepositIndex
    );
}
