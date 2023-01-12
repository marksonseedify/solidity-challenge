const { ethers } = require('hardhat');

function toEther(n) {
    return parseInt(ethers.utils.formatEther(n));
}

function toWei(n) {
    return ethers.utils.parseEther(n);
}

module.exports = {
    toEther,
    toWei,
};
