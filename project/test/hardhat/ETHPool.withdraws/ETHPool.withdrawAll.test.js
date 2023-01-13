const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { toEther, toWei } = require('../helpers/helpers');

let owner, alice, bob, charlie, delta, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, delta, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.withdrawAll', function () {
    it('it verifies withdraw data, including UserWithdrawal(...), when Alice & Bob take tehir rewards', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        const aliceDeposit = toWei('100');
        const bobDeposit = toWei('300');

        await pool.connect(alice).userDeposit({ value: aliceDeposit });
        await pool.connect(bob).userDeposit({ value: bobDeposit });

        await pool.depositRewards({ value: toWei('500') });

        assert.equal(toEther(await pool.pendingRewards(alice.address)), 125);
        assert.equal(toEther(await pool.pendingRewards(bob.address)), 375);

        // save balances and rewards before withdrawl
        const aliceOldBalance = await ethers.provider.getBalance(
            alice.address
        );
        const bobOldBalance = await ethers.provider.getBalance(bob.address);
        const alicePendingRewards = await pool.pendingRewards(alice.address);
        const bobPendingRewards = await pool.pendingRewards(bob.address);

        await withdrawAll.connect(alice).withdrawAll();
        await expect(withdrawRewards.connect(bob).withdrawAll())
            .to.emit(pool, 'Withdrawl')
            .withArgs(bob.address, bobPendingRewards + bobDeposit, 0);

        assert.equal(
            await ethers.provider.getBalance(alice.address),
            aliceOldBalance + alicePendingRewards + aliceDeposit
        );
        assert.equal(
            await ethers.provider.getBalance(bob.address),
            bobOldBalance + bobPendingRewards + bobDeposit
        );
    });
});
