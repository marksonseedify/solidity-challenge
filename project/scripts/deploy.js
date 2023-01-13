const hre = require('hardhat');

// npx hardhat run --network goerli scripts/deploy.js
async function main() {
    const ETHPool = await hre.ethers.getContractFactory('ETHPool');
    const ethpool = await ETHPool.deploy();

    await ethpool.deployed();

    console.log(`Deployed to ${ethpool.address}`);

    await hre.run('verify:verify', {
        address: ethpool.address,
        // see: https://hardhat.org/hardhat-runner/plugins/nomiclabs-hardhat-etherscan#using-programmatically
        // constructorArguments: [],
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
