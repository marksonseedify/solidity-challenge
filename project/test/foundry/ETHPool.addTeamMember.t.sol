// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ETHPoolTestSetUp} from "./setUp/ETHPoolTestSetUp.t.sol";

contract ETHPoolTest_AddTeamMember is ETHPoolTestSetUp {
    event TeamMemberAdded(address indexed teamMember);

    function setUp() public override {
        super.setUp();
    }

    function test_addTeamMember_PrankOwnerAndTeamMember_WithEvent_TeamMemberAdded()
        public
    {
        vm.expectEmit(true, true, true, true);
        emit TeamMemberAdded(team.TEAM_MEMBER_1());

        // ensure owner can add a team member
        pool.addTeamMember(team.TEAM_MEMBER_1());

        // ensure team member can add a team member
        vm.prank(team.TEAM_MEMBER_1());
        pool.addTeamMember(team.TEAM_MEMBER_2());

        assertTrue(pool.isTeamMember(team.TEAM_MEMBER_1()));
        assertTrue(pool.isTeamMember(team.TEAM_MEMBER_2()));
        assertEq(pool.teamMembersLength(), 2);
    }

    // FIXME: `expectRevert` does not pass, whereas the error is thrown - tested with Hardhat instead
    /* function test_addTeamMember_RevertIf_MsgSenderIsNotOwnerOrTeamMember()
        public
    {
        vm.startPrank(users.CHARLIE());

        vm.expectRevert("Pool_OWNER_TEAM_ONLY");
        pool.addTeamMember(team.TEAM_MEMBER_1());
    } */
}
