const hre = require('hardhat');

// npx hardhat run --network goerli scripts/ethBalanceInPool.js
async function main() {
    const ethBalance = parseFloat(
        hre.ethers.utils.formatEther(
            await hre.ethers.provider.getBalance(
                '0x000095E79eAC4d76aab57cB2c1f091d553b36ca0'
            )
        )
    );

    console.log(`There is ${ethBalance} ETH in the pool`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
