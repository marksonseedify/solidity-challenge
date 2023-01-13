// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";

import {Rewards} from "./Rewards.sol";
import {TeamManagement} from "./TeamManagement.sol";
import {UserData} from "./UserData.sol";

/**
 * @notice ETHPool is a contract that allows users to deposit ETH and earn
 *         interest on a weekly basis. New rewards are deposited manually into
 *         the pool by the ETHPool team each week.
 */
contract ETHPool is TeamManagement, Rewards, UserData {
    using Address for address payable;

    struct Withdrawals {
        uint256 amount;
        uint256 lastWithdrawlTime;
        // (2^16) / 52 = 1,260 years
        uint16 weeklyDepositIndex;
    }

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event Withdrawl(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed weeklyDepositIndex
    );

    function depositRewards() public payable override onlyOwnerOrTeam {
        super.depositRewards();
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
    ) public view override returns (uint256 pendingRewards) {
        super.pendingRewards(user);
        // Has the user deposited before the last weekly deposit from the team?
        if (usersDeposits[user].lastestTime < snapshotRewards.timestamp) {
            pendingRewards =
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
            pendingRewards =
                ((usersDeposits[user].total -
                    usersDeposits[user].lastDeposit) *
                    snapshotRewards.previousTotal) /
                snapshotDeposits;
        }
    }

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
