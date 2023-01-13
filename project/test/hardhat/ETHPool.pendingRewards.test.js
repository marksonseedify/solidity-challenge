const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('./helpers/helpers');

let owner, alice, bob, charlie, delta, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, delta, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.pendingRewards', function () {
    it('it computes rewards for Alice, Bob, Charlie & Delta', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: toWei('100') });
        await pool.connect(bob).userDeposit({ value: toWei('300') });

        await pool.depositRewards({ value: toWei('500') });
        /**
         * snapshotRewards & totalUsersDeposits should be the same, no
         * rewards deposited yet
         */
        assert.equal(
            toEther(await pool.snapshotTotalUsersDeposits()),
            toEther(await pool.totalUsersDeposits())
        );

        await pool.connect(charlie).userDeposit({ value: toWei('400') });
        // more ETH deposited
        assert.equal(toEther(await pool.totalUsersDeposits()), 800);

        // jump 1 week later to avoid 'WEEKLY_REWARDS_DEPOSIT' revert
        await ethers.provider.send('evm_increaseTime', [604800]);
        await pool.depositRewards({ value: toWei('1000') });

        const snapshotRewards = await pool.snapshotRewards();
        // 1000 , 500, 1500
        assert.equal(toEther(snapshotRewards.amount), 1000);
        assert.equal(toEther(snapshotRewards.previousTotal), 500);
        assert.equal(toEther(await pool.totalRewards()), 1500);

        await pool.connect(delta).userDeposit({ value: toWei('400') });

        assert.equal(toEther(await pool.pendingRewards(alice.address)), 187);
        assert.equal(toEther(await pool.pendingRewards(bob.address)), 562);
        assert.equal(toEther(await pool.pendingRewards(charlie.address)), 750);
        assert.equal(toEther(await pool.pendingRewards(delta.address)), 0);
    });

    it('fails on: NO_USERS_DEPOSITS', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: toWei('100') });

        await expect(pool.pendingRewards(alice.address)).to.be.revertedWith(
            'NO_USERS_DEPOSITS'
        );
    });
});
