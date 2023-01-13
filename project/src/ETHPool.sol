// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {EnumerableSet} from "openzeppelin-contracts/utils/structs/EnumerableSet.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @notice ETHPool is a contract that allows users to deposit ETH and earn
 *         interest on a weekly basis. New rewards are deposited manually into
 *         the pool by the ETHPool team each week.
 */
contract ETHPool is Ownable {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct SnapshotRewards {
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
    EnumerableSet.AddressSet private _teamMembers;
    uint256[] public weeklyRewardsDeposits;
    SnapshotRewards public snapshotRewards; // weekly rewards update
    uint256 public totalRewards;
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
    event TeamMemberAdded(address indexed teamMember);
    event TeamMemberRemoved(address indexed teamMember);

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

    modifier onlyOwnerOrTeam() {
        require(
            msg.sender == owner() || isTeamMember(msg.sender),
            "Pool_OWNER_TEAM_ONLY"
        );
        _;
    }

    /**
     * @notice Manage team members.
     * @dev Only the owner or a team member can update team members.
     *      As we use an EnumerableSet, we don't need to check if the
     *      `teamMember` is already in the set.
     */
    function addTeamMember(address teamMember) external onlyOwnerOrTeam {
        require(_teamMembers.add(teamMember), "MEMBER_EXISTS");
        emit TeamMemberAdded(teamMember);
    }

    /**
     * @notice Manage team members.
     * @dev Only the owner or other team member can update team members.
     *      As we use an EnumerableSet, we don't need to check if the
     *      `teamMember` has already been removed from the set.
     */
    function removeTeamMember(address teamMember) external onlyOwnerOrTeam {
        require(_teamMembers.remove(teamMember), "MEMBER_NOT_FOUND");
        emit TeamMemberRemoved(teamMember);
    }

    function teamMembersLength() external view returns (uint256) {
        return _teamMembers.length();
    }

    function isTeamMember(address teamMember) public view returns (bool) {
        return _teamMembers.contains(teamMember);
    }

    /**
     * @notice Deposit ETH for rewards into the pool.
     * @dev Only ETHPool team can deposit rewards.
     */
    function depositRewards() external payable onlyOwnerOrTeam {
        require(msg.value > 0, "REWARDS_ZERO");

        snapshotRewards.timestamp = block.timestamp;
        snapshotRewards.amount = msg.value;
        snapshotRewards.lastTotal = totalRewards;

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
