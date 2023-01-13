const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei, getBalance } = require('../helpers/helpers');
const {
    userDeposit,
    isDepositDataReseted,
} = require('../helpers/depositHelper');
const { pendingRewardsOf } = require('../helpers/pendingRewardsHelper');

let owner, alice, bob, charlie, delta, member2, member3;
let pool;

before(async () => {
    [owner, alice, bob, charlie, delta, member2, member3] =
        await ethers.getSigners();
});

beforeEach(async () => {
    const ETHPool = await ethers.getContractFactory('ETHPool');
    pool = await ETHPool.deploy();
    await pool.deployed();
});

describe('ETHPool.withdrawPendingRewards', function () {
    it('it verifies withdraw data, including UserWithdrawal(...), when Alice & Bob take tehir rewards', async function () {
        const aliceDeposit = 100;
        const bobDeposit = 300;

        await userDeposit(pool, alice, aliceDeposit);
        await userDeposit(pool, bob, bobDeposit);

        // save users balances
        const aliceOldBalance = await getBalance(alice);
        const bobOldBalance = await getBalance(bob);

        await pool.depositRewards({ value: toWei('500') });
        const currentWeek = await pool.weekCounter();

        const alicePendingRewards = await pendingRewardsOf(pool, alice);
        const bobPendingRewards = await pendingRewardsOf(pool, bob);
        // save users rewards
        assert.equal(alicePendingRewards, 125);
        assert.equal(bobPendingRewards, 375);

        await pool.connect(alice).withdrawPendingRewards();
        // verify event emittance and its parameters
        await expect(pool.connect(bob).withdrawPendingRewards())
            .to.emit(pool, 'Withdrawl')
            .withArgs(bob.address, toWei(bobPendingRewards.toString()), 1);

        // verify balances after withdrawl: equal to old blance + rewards
        assert.equal(
            await getBalance(alice),
            aliceOldBalance + alicePendingRewards
        );
        assert.equal(await getBalance(bob), bobOldBalance + bobPendingRewards);

        const aliceWithdrawls = await pool.usersWithdrawals(alice.address);
        const bobWithdrawls = await pool.usersWithdrawals(bob.address);

        assert.equal(aliceWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(bobWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(toEther(aliceWithdrawls.amount), alicePendingRewards);
        assert.equal(toEther(bobWithdrawls.amount), bobPendingRewards);
    });

    it('fails on: WITHDRAW_0', async function () {
        await pool.connect(bob).userDeposit({ value: toWei('100') });

        await pool.depositRewards({ value: toWei('500') });

        await expect(
            pool.connect(alice).withdrawPendingRewards()
        ).to.be.revertedWith('WITHDRAW_0');
    });

    it('fails on: WITHDRAW_ONCE_WEEK', async function () {
        await pool.connect(alice).userDeposit({ value: toWei('100') });

        await pool.depositRewards({ value: toWei('500') });

        await pool.connect(alice).withdrawPendingRewards();
        await expect(
            pool.connect(alice).withdrawPendingRewards()
        ).to.be.revertedWith('WITHDRAW_ONCE_WEEK');
    });
});
