const { ethers } = require("hardhat");

async function main() {
  // Retrieve the contract factories and deployer's address
  const [deployer] = await ethers.getSigners();
  const EnergyTradingFactory = await ethers.getContractFactory("EnergyTrading");

  // Deploy the contract
  console.log("Deploying the EnergyTrading contract...");
  const energyTrading = await EnergyTradingFactory.deploy();
  await energyTrading.deployTransaction.wait(); // Wait for the deployment transaction to be mined

  console.log("EnergyTrading contract deployed to:", energyTrading.address);
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
