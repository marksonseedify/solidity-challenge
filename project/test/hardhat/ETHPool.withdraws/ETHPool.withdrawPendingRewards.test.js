const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('../helpers/helpers');

let owner, alice, bob, charlie, delta, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, delta, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.withdrawPendingRewards', function () {
    it('it verifies withdraw data, including UserWithdrawal(...), when Alice & Bob take tehir rewards', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        const aliceDeposit = toWei('100');
        const bobDeposit = toWei('300');

        await pool.connect(alice).userDeposit({ value: aliceDeposit });
        await pool.connect(bob).userDeposit({ value: bobDeposit });

        await pool.depositRewards({ value: toWei('500') });
        const currentWeek = await pool.nextDepositWeek();

        assert.equal(toEther(await pool.pendingRewards(alice.address)), 125);
        assert.equal(toEther(await pool.pendingRewards(bob.address)), 375);

        // save balances and rewards before withdrawl
        const aliceOldBalance = toEther(
            await ethers.provider.getBalance(alice.address)
        );
        const bobOldBalance = toEther(
            await ethers.provider.getBalance(bob.address)
        );
        const alicePendingRewards = toEther(
            await pool.pendingRewards(alice.address)
        );
        const bobPendingRewards = toEther(
            await pool.pendingRewards(bob.address)
        );

        await pool.connect(alice).withdrawPendingRewards();
        // verify event emittance and its parameters
        await expect(pool.connect(bob).withdrawPendingRewards())
            .to.emit(pool, 'Withdrawl')
            .withArgs(bob.address, toWei(bobPendingRewards.toString()), 1);

        // verify balances after withdrawl: equal to old blance + rewards
        assert.equal(
            toEther(await ethers.provider.getBalance(alice.address)),
            aliceOldBalance + alicePendingRewards
        );
        assert.equal(
            toEther(await ethers.provider.getBalance(bob.address)),
            bobOldBalance + bobPendingRewards
        );

        const aliceWithdrawls = await pool.usersWithdrawals(alice.address);
        const bobWithdrawls = await pool.usersWithdrawals(bob.address);

        assert.equal(aliceWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(bobWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(toEther(aliceWithdrawls.amount), alicePendingRewards);
        assert.equal(toEther(bobWithdrawls.amount), bobPendingRewards);
    });

    it('fails on: NO_REWARDS_FOR_USER', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(bob).userDeposit({ value: toWei('100') });

        await pool.depositRewards({ value: toWei('500') });

        await expect(
            pool.connect(alice).withdrawPendingRewards()
        ).to.be.revertedWith('NO_REWARDS_FOR_USER');
    });

    it('fails on: WITHDRAW_ONCE_WEEK', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(alice).userDeposit({ value: toWei('100') });

        await pool.depositRewards({ value: toWei('500') });

        await pool.connect(alice).withdrawPendingRewards();
        await expect(
            pool.connect(alice).withdrawPendingRewards()
        ).to.be.revertedWith('WITHDRAW_ONCE_WEEK');
    });
});
