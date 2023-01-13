const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('./helpers/helpers');

let owner, alice, bob, charlie, member1, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, member1, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.depositRewards', function () {
    it('lets owner deposits rewards and check RewardsDeposit(...) emittance', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: toWei('100') });

        await expect(pool.depositRewards({ value: toWei('10') })).to.emit(
            pool,
            'RewardsDeposit'
        );

        const snapshotRewards = await pool.snapshotRewards();
        const snapshotDeposits = toEther(await pool.snapshotDeposits());

        const weekCounter = await pool.weekCounter();

        // verify pool.snapshotRewards parameters
        expect(snapshotRewards.timestamp).to.not.equal(0);
        assert.equal(toEther(snapshotRewards.amount), 10);
        assert.equal(toEther(snapshotRewards.previousTotal), 0);

        assert.equal(snapshotDeposits, 100);

        assert.equal(toEther(await pool.totalRewards()), 10);
        assert.equal(
            toEther(await pool.weeklyRewardsDeposits(weekCounter - 1)),
            10
        );

        assert.equal(weekCounter, 1);
    });

    it('fails on: NO_USERS_DEPOSITS', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await expect(pool.depositRewards({ value: '100' })).to.be.revertedWith(
            'NO_USERS_DEPOSITS'
        );
    });

    it('fails on: WEEKLY_REWARDS_DEPOSIT', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: '100' });

        await pool.depositRewards({ value: '10' });

        await expect(pool.depositRewards({ value: '10' })).to.be.revertedWith(
            'WEEKLY_REWARDS_DEPOSIT'
        );
    });

    it('reverts on Pool_OWNER_TEAM_ONLY', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: '100' });

        await expect(
            pool.connect(alice).depositRewards({ value: '10' })
        ).to.be.revertedWith('Pool_OWNER_TEAM_ONLY');
    });

    it('reverts on DEPOSIT_REWARDS_ZERO', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: '100' });

        await expect(pool.depositRewards({ value: '0' })).to.be.revertedWith(
            'DEPOSIT_REWARDS_ZERO'
        );
    });
});
