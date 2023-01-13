const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('../helpers/helpers');

let owner, alice, bob, charlie, delta, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, delta, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.withdrawAll', function () {
    it('it verifies withdraw data, including UserWithdrawal(...), when Alice & Bob withdraw ALL', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        const aliceDeposit = toWei('100');
        const bobDeposit = toWei('300');

        await pool.connect(alice).userDeposit({ value: aliceDeposit });
        await pool.connect(bob).userDeposit({ value: bobDeposit });

        await pool.depositRewards({ value: toWei('500') });
        const currentWeek = await pool.weekCounter();

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

        await pool.connect(alice).withdrawAll();
        // verify event emittance and its parameters
        await expect(pool.connect(bob).withdrawAll())
            .to.emit(pool, 'Withdrawl')
            .withArgs(
                bob.address,
                toWei((bobPendingRewards + toEther(bobDeposit)).toString()),
                1
            );

        // verify balances after withdrawl: equal to old blance + rewards
        assert.equal(
            toEther(await ethers.provider.getBalance(alice.address)),
            aliceOldBalance + alicePendingRewards + toEther(aliceDeposit)
        );
        assert.equal(
            toEther(await ethers.provider.getBalance(bob.address)),
            bobOldBalance + bobPendingRewards + toEther(bobDeposit)
        );

        const aliceWithdrawls = await pool.usersWithdrawals(alice.address);
        const bobWithdrawls = await pool.usersWithdrawals(bob.address);

        assert.equal(aliceWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(bobWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(
            toEther(aliceWithdrawls.amount),
            alicePendingRewards + toEther(aliceDeposit)
        );
        assert.equal(
            toEther(bobWithdrawls.amount),
            bobPendingRewards + toEther(bobDeposit)
        );
    });
});
