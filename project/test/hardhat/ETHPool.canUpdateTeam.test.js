const { expect } = require('chai');
const { ethers } = require('hardhat');

let owner, alice, bob, charlie, member1, member2, member3;

before(async () => {
    [owner, alice, bob, charlie, member1, member2, member3] =
        await ethers.getSigners();
});

describe('ETHPool.canUpdateTeam', function () {});
