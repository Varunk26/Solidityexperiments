//import ethers

const {ethers} = require("hardhat");

async function main() {
  console.log(ethers);
  // 1.Somehow tell the script we want to deploy the 'NFTee.sol' contract
  const contract = await ethers.getContractFactory("NFTee");

  // 2.Deploy it
  const deployedContract = await contract.deploy();

  //2.1
  await deployedContract.deployed();

  // 3.Print the address
  console.log("NFT Contract deployed to: ", deployedContract.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});