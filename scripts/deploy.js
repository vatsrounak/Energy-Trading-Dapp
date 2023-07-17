const hre = require("hardhat");

async function main() {
  // Retrieve the contract factories and deployer's address
  const [deployer] = await hre.ethers.getSigners();
  
  // the below code is used to create an instance of the EnergyTrading. sol smart contract
  const EnergyTradingFactory = await hre.ethers.getContractFactory("EnergyTrading");

  // Deploy the contract
console.log("Deploying the EnergyTrading contract...");
const energyTrading = await EnergyTradingFactory.deploy();
await energyTrading.deployed(); // Wait for the deployment transaction to be mined

console.log("EnergyTrading contract deployed to:", energyTrading.address);
}

// Execute the deployment
main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});