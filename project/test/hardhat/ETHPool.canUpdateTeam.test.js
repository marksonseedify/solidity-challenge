const { expect } = require('chai');
const { ethers } = require('hardhat');

let owner, alice, bob, charlie, member1, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, member1, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.canUpdateTeam', function () {
    it('addTeamMember: revert when msg.sender is not owner, nor team member', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await expect(
            pool.connect(charlie).addTeamMember(member1.address)
        ).to.be.revertedWith('Pool_OWNER_TEAM_ONLY');
    });

    it('removeTeamMember: revert when msg.sender is not owner, nor team member', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        pool.addTeamMember(member1.address);

        await expect(
            pool.connect(charlie).removeTeamMember(member1.address)
        ).to.be.revertedWith('Pool_OWNER_TEAM_ONLY');
    });
});
