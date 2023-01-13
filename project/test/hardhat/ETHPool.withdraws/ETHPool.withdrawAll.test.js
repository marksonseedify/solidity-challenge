const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei, getBalance } = require('../helpers/helpers');
const { userDeposit } = require('../helpers/depositHelper');
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

describe('ETHPool.withdrawAll', function () {
    it('it verifies withdraw data, including UserWithdrawal(...), when Alice & Bob withdraw ALL', async function () {
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

        await pool.connect(alice).withdrawAll();

        // verify event emittance and its parameters
        await expect(pool.connect(bob).withdrawAll())
            .to.emit(pool, 'Withdrawl')
            .withArgs(
                bob.address,
                toWei((bobPendingRewards + bobDeposit).toString()),
                1
            );

        // verify balances after withdrawl: equal to old blance + rewards
        assert.equal(
            await getBalance(alice),
            aliceOldBalance + alicePendingRewards + aliceDeposit
        );
        assert.equal(
            await getBalance(bob),
            bobOldBalance + bobPendingRewards + bobDeposit
        );

        const aliceWithdrawls = await pool.usersWithdrawals(alice.address);
        const bobWithdrawls = await pool.usersWithdrawals(bob.address);

        assert.equal(aliceWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(bobWithdrawls.withdrawWeekIndex, currentWeek);
        assert.equal(
            toEther(aliceWithdrawls.amount),
            alicePendingRewards + aliceDeposit
        );
        assert.equal(
            toEther(bobWithdrawls.amount),
            bobPendingRewards + bobDeposit
        );
    });
});
