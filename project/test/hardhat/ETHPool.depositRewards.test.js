const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('./helpers/helpers');

let owner, alice, bob, charlie, member1, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, member1, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.depositRewards', function () {
    it('depositRewards: owner deposits rewards and check RewardsDeposit(...) emittance', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        console.log(
            'owner.balance: ',
            ethers.utils.formatEther(
                await ethers.provider.getBalance(owner.address)
            )
        );

        await expect(pool.depositRewards({ value: toWei('10') })).to.emit(
            pool,
            'RewardsDeposit'
        );

        const snapshot = await pool.snapshotRewards();
        const nextWeek = await pool.nextWeek();

        // verify pool.snapshotRewards parameters
        expect(snapshot.timestamp).to.not.equal(0);
        assert.equal(toEther(snapshot.amount), 10);
        assert.equal(toEther(snapshot.lastTotal), 0);

        assert.equal(toEther(await pool.totalRewards()), 10);
        assert.equal(
            toEther(await pool.weeklyRewardsDeposits(nextWeek - 1)),
            10
        );

        assert.equal(nextWeek, 1);
    });
});
