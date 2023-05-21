require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC = process.env.RPC;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    arbitrum_goerli: {
      url: RPC,
      accounts: [PRIVATE_KEY]
    }
  },
};
