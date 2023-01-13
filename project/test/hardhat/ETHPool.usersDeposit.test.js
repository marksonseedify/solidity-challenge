const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('./helpers/helpers');

let owner, alice, bob, charlie, member1, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, member1, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.usersDeposit', function () {
    it('verifies deposit data, including UsersDeposit(...) event, when Alice has deposited 1 Ether', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await expect(pool.connect(alice).userDeposit({ value: toWei('1') }))
            .to.emit(pool, 'UsersDeposit')
            .withArgs(alice.address, toWei('1'));

        const aliceDeposit = await pool.usersDeposits(alice.address);
        // verify pool.usersDeposits[alice] parameters
        assert.equal(toEther(aliceDeposit.lastDeposit), 1);
        expect(aliceDeposit.lastestTime).to.not.equal(0);
        assert.equal(toEther(aliceDeposit.lastDeposit), 1);

        assert.equal(toEther(await pool.totalUsersDeposits()), 1);
    });
});
