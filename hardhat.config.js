require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
// require("@nomiclabs/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.19",
// };
module.exports = {
  solidity: "0.8.19",
  networks: {
    rinkeby: {
      url: process.env.ALCHEMY_API_KEY_URL,
      accounts: [process.env.RINKEBY_PRIVATE_KEY],
    },
    goerli: {
      url: process.env.ALCHEMY_API_KEY_URL2,
      accounts: [process.env.GOERLI_PRIV],
    },
    sep: {
      url: process.env.ALCHEMY_API_KEY_URL3,
      accounts: [process.env.GOERLI_PRIV],
    },
  },
  etherscan: {
    apiKey: {
      sep: 'abc',
    },
    customChains: [
      {
        network: 'sep',
        chainId: 534351,
        urls: {
          apiURL: 'https://sepolia-blockscout.scroll.io/api',
          browserURL: 'https://sepolia-blockscout.scroll.io/',
        },
      },
    ],
  },
};

