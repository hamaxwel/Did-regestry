const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  // Deploy Forwarder
  const Forwarder = await ethers.getContractFactory("Forwarder");
  const forwarder = await Forwarder.deploy();
  await forwarder.deployed();
  console.log("Forwarder deployed at:", forwarder.address);

  // Deploy DIDRegistry (UUPS)
  const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
  const registry = await upgrades.deployProxy(
    DIDRegistry,
    [deployer.address, forwarder.address],
    { initializer: "initialize", kind: "uups" }
  );
  await registry.deployed();
  console.log("DIDRegistry deployed at:", registry.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 