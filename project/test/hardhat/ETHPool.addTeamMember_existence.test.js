const { expect } = require('chai');
const { ethers } = require('hardhat');

let owner, alice, bob, charlie, member1, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, member1, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.addTeamMember_existence', function () {
    it('addTeamMember: revert if the team already exists in the set', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        pool.addTeamMember(member1.address);

        await expect(pool.addTeamMember(member1.address)).to.be.revertedWith(
            'MEMBER_EXISTS'
        );
    });
});
