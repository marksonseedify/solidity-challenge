const { ethers } = require('hardhat');
const { toEther, toWei } = require('./helpers');

async function userDeposit(pool, user, amount) {
    await pool.connect(user).userDeposit({ value: toWei(amount.toString()) });
}

async function isDepositDataReseted(pool, user) {
    const userDepositData = await pool.usersDeposits(user.address);

    assert.equal(toEther(userDepositData.lastDeposit), 0);
    assert.equal(userDepositData.lastestTime, 0);
    assert.equal(toEther(userDepositData.total), 0);
}

module.exports = {
    userDeposit,
    isDepositDataReseted,
};
