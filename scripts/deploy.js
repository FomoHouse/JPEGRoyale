// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const arbitrumGoerliVRFCoordinator = "0x6D80646bEAdd07cE68cab36c27c626790bBcf17f";
  const arbitrumGoerliVRFSubscriptionId = "8";
  const arbitrumGoerliVRFKeyHash = "0x83d1b6e3388bed3d76426974512bb0d270e9542a765cd667242ea26c0cc0b730";

  const JPEGRoyale = await hre.ethers.getContractFactory("JPEGRoyale");
  const jpegRoyale = await JPEGRoyale.deploy(
    arbitrumGoerliVRFCoordinator,
    arbitrumGoerliVRFSubscriptionId,
    arbitrumGoerliVRFKeyHash
  );

  await jpegRoyale.deployed();

  console.log(`Deployed JPEGRoyale contract to ${jpegRoyale.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
