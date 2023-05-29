require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const ALCHEMY_HTTP_URL_ARBITRUM_GEORLI = process.env.ALCHEMY_HTTP_URL_ARBITRUM_GEORLI;
const ALCHEMY_HTTP_URL_GEORLI = process.env.ALCHEMY_HTTP_URL_GEORLI;
const ETHERSCAN_API_KEY_ARBITRUM_GEORLI = process.env.ETHERSCAN_API_KEY_ARBITRUM_GEORLI;
const ETHERSCAN_API_KEY_GEORLI = process.env.ETHERSCAN_API_KEY_GEORLI;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    arbitrum_goerli: {
      url: ALCHEMY_HTTP_URL_ARBITRUM_GEORLI,
      accounts: [PRIVATE_KEY]
    },
    goerli: {
      url: ALCHEMY_HTTP_URL_GEORLI,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      arbitrumGoerli: ETHERSCAN_API_KEY_ARBITRUM_GEORLI,
      goerli: ETHERSCAN_API_KEY_GEORLI
    }
  }
};
