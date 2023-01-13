// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {EnumerableSet} from "openzeppelin-contracts/utils/structs/EnumerableSet.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

abstract contract TeamManagement is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _teamMembers;

    event TeamMemberAdded(address indexed teamMember);
    event TeamMemberRemoved(address indexed teamMember);

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
}
