const { ethers } = require("hardhat");

async function main() {

  const arbitrumGoerliVRFCoordinator = "0x6D80646bEAdd07cE68cab36c27c626790bBcf17f";
  const arbitrumGoerliVRFSubscriptionId = "8";
  const arbitrumGoerliVRFKeyHash = "0x83d1b6e3388bed3d76426974512bb0d270e9542a765cd667242ea26c0cc0b730";
  const gameStarter = ["0xA21B8cF5C9A5ED69b18FFB9e55d13c96A5741C16"];
  const admin = ["0xA21B8cF5C9A5ED69b18FFB9e55d13c96A5741C16"];
  const platformAddress = "0xA21B8cF5C9A5ED69b18FFB9e55d13c96A5741C16";
  const gelatoProxyAddress = "0x828be1f99c1974cd46c0a92186b1cbfb3ac71610";
  const automate = "0xa5f9b728ecEB9A1F6FCC89dcc2eFd810bA4Dec41";
  const taskCreator = "0xA21B8cF5C9A5ED69b18FFB9e55d13c96A5741C16";

  const JPEGRoyaleContract = await ethers.getContractFactory("JPEGRoyale");
  const deployedJPEGRoyaleContract = await JPEGRoyaleContract.deploy(
    arbitrumGoerliVRFCoordinator,
    arbitrumGoerliVRFSubscriptionId,
    arbitrumGoerliVRFKeyHash,
    gameStarter,
    admin,
    platformAddress,
    gelatoProxyAddress,
    automate,
    taskCreator
  );

  await deployedJPEGRoyaleContract.deployed();

  console.log(`Deployed JPEGRoyale contract to ${deployedJPEGRoyaleContract.address}`);

  await hre.run("verify:verify", {
    address: deployedJPEGRoyaleContract.address,
    constructorArguments: [
      arbitrumGoerliVRFCoordinator,
      arbitrumGoerliVRFSubscriptionId,
      arbitrumGoerliVRFKeyHash,
      gameStarter,
      admin,
      platformAddress,
      gelatoProxyAddress,
      automate,
      taskCreator
    ]
  });

  console.log("\nSuccessfully verified JPEGRoyale contract on Ether/Arbiscan");
}


main() 
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
