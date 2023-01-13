// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Rewards} from "./Rewards.sol";
import {TeamManagement} from "./TeamManagement.sol";
import {UserData} from "./UserData.sol";

/**
 * @notice ETHPool is a contract that allows users to deposit ETH and earn
 *         interest on a weekly basis. New rewards are deposited manually into
 *         the pool by the ETHPool team each week.
 */
contract ETHPool is TeamManagement, Rewards, UserData {
    function depositRewards() public payable onlyOwnerOrTeam {
        require(totalUsersDeposits > 0, "NO_USERS_DEPOSITS");
        // require(, "ONLY_WEEKLY_REWARDS");

        _depositRewards();

        snapshotDeposits = totalUsersDeposits;
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
    ) public view override returns (uint256 rewards) {
        require(snapshotDeposits > 0, "NO_USERS_DEPOSITS");

        // Has the user deposited before the last weekly deposit from the team?
        if (usersDeposits[user].lastestTime < snapshotRewards.timestamp) {
            rewards =
                (usersDeposits[user].total * totalRewards) /
                snapshotDeposits;
        }
        /**
         * @dev With the deposit limitation of once a week this part is not
         * subject to drain attacks.
         * Though if we wanted to let users deposit new amounts before new
         * rewards are deposited we would need implement a more complex
         * calculation on this part of the if statement.
         *
         * We could even set the limit on the rewards withdraw. User can
         * withdraw their deposit any time, but there rewards only once a week.
         * This would allow users to deposit ETH at any time without being
         * able to drain the contract.
         */
        else {
            /** @dev Deduct last deposit of user from total deposit by user,
             * multiply by amount of rewards in contract before adding new
             * rewards, divide by snapshotDeposits
             */
            rewards =
                ((usersDeposits[user].total -
                    usersDeposits[user].lastDeposit) *
                    snapshotRewards.previousTotal) /
                snapshotDeposits;
        }
    }

    /**
     * @notice Withdraw pending rewards.
     * @dev For calculations simplicity, we authorize users to withdraw only
     *      once a week.
     */
    function withdrawPendingRewards() external {
        _withdraw(pendingRewards(msg.sender), nextDepositWeek);
    }

    /**
     * @notice Withdraw all deposits and rewards simultaneously.
     */
    function withdrawAll() external {
        _withdraw(
            pendingRewards(msg.sender) + usersDeposits[msg.sender].total,
            nextDepositWeek
        );
    }
}
