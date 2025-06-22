const { ethers } = require("hardhat");
const { TypedDataUtils } = require("ethers-eip712");

async function main() {
  // Addresses from deployment
  const forwarderAddress = process.env.FORWARDER_ADDRESS;
  const registryAddress = process.env.REGISTRY_ADDRESS;
  if (!forwarderAddress || !registryAddress) {
    throw new Error("Set FORWARDER_ADDRESS and REGISTRY_ADDRESS env vars");
  }

  // Get contracts
  const Forwarder = await ethers.getContractAt("Forwarder", forwarderAddress);
  const Registry = await ethers.getContractAt("DIDRegistry", registryAddress);

  // Get user (signer) and relayer
  const [relayer, user] = await ethers.getSigners();
  console.log("User:", user.address);
  console.log("Relayer:", relayer.address);

  // Prepare meta-tx data
  const did = "did:example:metauser";
  const metadata = "{\"name\":\"Meta User\"}";
  const data = Registry.interface.encodeFunctionData("registerDID", [did, metadata]);

  // Get nonce
  const nonce = await Forwarder.getNonce(user.address);

  // EIP-712 domain and request
  const domain = {
    name: "MinimalForwarder",
    version: "0.0.1",
    chainId: await relayer.provider.getNetwork().then(n => n.chainId),
    verifyingContract: forwarderAddress
  };
  const types = {
    ForwardRequest: [
      { name: "from", type: "address" },
      { name: "to", type: "address" },
      { name: "value", type: "uint256" },
      { name: "gas", type: "uint256" },
      { name: "nonce", type: "uint256" },
      { name: "data", type: "bytes" }
    ]
  };
  const request = {
    from: user.address,
    to: registryAddress,
    value: 0,
    gas: 1_000_000,
    nonce,
    data
  };

  // Sign meta-tx
  const signature = await user.signTypedData(domain, types, request);

  // Relayer sends meta-tx
  const tx = await Forwarder.connect(relayer).execute(request, signature, { gasLimit: 1_500_000 });
  await tx.wait();
  console.log("Meta-transaction sent!");

  // Query DID
  const didInfo = await Registry.getDID(did);
  console.log("DID Info:", didInfo);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
}); 