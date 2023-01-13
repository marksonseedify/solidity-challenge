const { ethers } = require('hardhat');
const { toEther, toWei } = require('./helpers');

async function pendingRewardsOf(pool, user) {
    return toEther(await pool.pendingRewards(user.address));
}

module.exports = {
    pendingRewardsOf,
};
