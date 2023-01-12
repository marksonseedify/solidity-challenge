// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ETHPoolTestSetUp} from "./setUp/ETHPoolTestSetUp.t.sol";

contract ETHPoolTest_RemoveTeamMember is ETHPoolTestSetUp {
    event TeamMemberRemoved(address indexed teamMember);

    function setUp() public override {
        super.setUp();
    }

    function test_removeTeamMember_PrankOwnerAndTeamMember_WithEvent_TeamMemberRemoved()
        public
    {
        pool.addTeamMember(team.TEAM_MEMBER_1());
        pool.addTeamMember(team.TEAM_MEMBER_2());
        pool.addTeamMember(team.TEAM_MEMBER_3());

        vm.expectEmit(true, true, true, true);
        emit TeamMemberRemoved(team.TEAM_MEMBER_1());
        // ensure owner can remove a team member
        pool.removeTeamMember(team.TEAM_MEMBER_1());

        // ensure team member can remove a team member
        vm.prank(team.TEAM_MEMBER_3());
        pool.removeTeamMember(team.TEAM_MEMBER_2());

        // members 1 and 2 should be removed
        assertFalse(pool.isTeamMember(team.TEAM_MEMBER_1()));
        assertFalse(pool.isTeamMember(team.TEAM_MEMBER_2()));
        // member 3 should still be a team member
        assertTrue(pool.isTeamMember(team.TEAM_MEMBER_3()));

        assertEq(pool.teamMembersLength(), 1);
    }

    function test_removeTeamMember_RevertIf_MsgSenderIsNotOwnerOrTeamMember()
        public
    {
        pool.addTeamMember(team.TEAM_MEMBER_1());

        vm.prank(users.CHARLIE());

        vm.expectRevert("ETHPool: owner or team member only");
        pool.removeTeamMember(team.TEAM_MEMBER_1());
    }
}
