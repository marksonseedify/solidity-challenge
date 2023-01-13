const { ethers } = require('hardhat');

function toEther(n) {
    return parseInt(ethers.utils.formatEther(n));
}

function toWei(n) {
    return ethers.utils.parseEther(n);
}

async function getBalance(user) {
    return toEther(await ethers.provider.getBalance(user.address));
}

module.exports = {
    toEther,
    toWei,
    getBalance,
};
