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

    it.skip('fails on: DEPOSIT_ZERO', async function () {});

    it('fails on: DEPOSIT_ONCE_WEEK', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        pool.connect(alice).userDeposit({ value: toWei('1') });

        await expect(
            pool.connect(alice).userDeposit({ value: toWei('1') })
        ).to.revertedWith('DEPOSIT_ONCE_WEEK');
    });

    it('waits 1 week before second deposit to verify Bob can deposit multiple times', async function () {
        const ETHPool = await ethers.getContractFactory('ETHPool');
        const pool = await ETHPool.deploy();
        await pool.deployed();

        await pool.connect(bob).userDeposit({ value: toWei('1') });

        await ethers.provider.send('evm_increaseTime', [604800]);

        await pool.connect(bob).userDeposit({ value: toWei('1') });

        assert.equal(toEther(await pool.totalUsersDeposits()), 2);
    });
});
