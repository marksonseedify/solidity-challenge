// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract UserData {
    struct UserDeposit {
        uint256 lastDeposit;
        uint256 lastestTime;
        uint256 total;
    }

    /*//////////////////////////////////////////////////////////////
                            TRACK USER'S DATA
    //////////////////////////////////////////////////////////////*/
    mapping(address => UserDeposit) public usersDeposits;
    // mapping(address => Withdrawals) public usersWithdrawals;
    uint256 public totalUsersDeposits;

    event UsersDeposit(address indexed user, uint256 indexed amount);

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
}
