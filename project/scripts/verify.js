const hre = require('hardhat');

// npx hardhat run --network bscTest scripts/verify.js
async function main() {
    await hre.run('verify:verify', {
        address: '0xF9C1b8AC4873117ABDB5e18d25B3f66CE8282397',
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
