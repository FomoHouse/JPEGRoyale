// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const arbitrumGoerliEthPriceFeedAddress = "0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08";
  const arbitrumGoerliVRFCoordinator = "";
  const arbitrumGoerliVRFSubscriptionId = "";
  const arbitrumGoerliVRFKeyHash = "";
  const daoWalletAddress = "";

  const JPEGRoyale = await hre.ethers.getContractFactory("JPEGRoyale");
  const jpegRoyale = await JPEGRoyale.deploy(
    arbitrumGoerliEthPriceFeedAddress,
    arbitrumGoerliVRFCoordinator,
    arbitrumGoerliVRFSubscriptionId,
    arbitrumGoerliVRFKeyHash,
    daoWalletAddress
  );

  await jpegRoyale.deployed();

  console.log("Deployed JPEGRoyale contract");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
