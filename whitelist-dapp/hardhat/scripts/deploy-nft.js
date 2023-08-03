const hre = require("hardhat");
//const { Contract } = require("hardhat/internal/hardhat-network/stack-traces/model");

const contractAddress = "0xE1b17CCae1cD60A7D9a94Ea75144d3874D053704";

async function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

async function main() {
    //deploy crypto dev contract
    const nftContract = await hre.ethers.deployContract("CryptoDev", [contractAddress]);

    // wait for contract to deploy
    await nftContract.waitForDeployment();

    //print address of deployed contract
    console.log("NFT Contract Address:", nftContract.target);

    //Sleep for 30 secs while etherscan indexes
    await sleep(30 * 1000);

    //verify contract on etherscan
    await hre.run("verify:verify", {
        address: nftContract.target,
        constructorArguments: [contractAddress],
    });
}
// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });