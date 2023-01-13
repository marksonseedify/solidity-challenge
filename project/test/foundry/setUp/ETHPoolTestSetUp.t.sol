// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ETHPool} from "../../../src/ETHPool.sol";
import {TeamMembers} from "../../fixtures/TeamMembers.sol";
import {Users} from "../../fixtures/Users.sol";

contract ETHPoolTestSetUp is Test {
    ETHPool public pool;
    TeamMembers public team;
    Users public users;

    function setUp() public virtual {
        pool = new ETHPool();
        team = new TeamMembers();
        users = new Users();

        vm.deal(users.ALICE(), 7 ether);
        vm.deal(users.BOB(), 7 ether);
    }
}
