// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";

abstract contract UserData {
    using Address for address payable;

    struct UserDeposit {
        uint256 lastDeposit;
        uint256 lastestTime;
        uint256 total;
    }

    struct UserWithdrawal {
        uint256 amount;
        uint256 lastWithdrawlTime;
        // (2^16) / 52 = 1,260 years
        uint16 weeklyDepositIndex;
    }

    /*//////////////////////////////////////////////////////////////
                            TRACK USER'S DATA
    //////////////////////////////////////////////////////////////*/
    mapping(address => UserDeposit) public usersDeposits;
    // mapping(address => UserWithdrawal) public usersWithdrawals;
    uint256 public totalUsersDeposits;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event UsersDeposit(address indexed user, uint256 indexed amount);
    event Withdrawl(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed weeklyDepositIndex
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
     * @dev Withdraw pending rewards.
    // re-entreency guard / check effects interaction pattern

    /**
     * @notice Withdraw all deposits and rewards simultaneously.
     */
    // re-entreency guard / check effects interaction pattern
}
