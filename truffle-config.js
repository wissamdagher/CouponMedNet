require('babel-register');
require('babel-polyfill');
const PrivateKeyProvider = require("@truffle/hdwallet-provider");


const privateKey = "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3";

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    quickstartWallet: {
      provider: () => new PrivateKeyProvider(privateKey, "http://localhost:8545"),
      network_id: "*"
    },
    quorum: {
      host: "127.0.0.1",
      port: 22000, // replace with quorum node port you wish to connect to
      network_id: "10",
      gas: 4500000,
      gasPrice: 0,
      from: '0xf6a841a6bf0813cbb5d44e995b3b584169f36c4e',
      type: "quorum"
    }
  },
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      version: '>=0.7.0 <0.9.0',
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: "byzantium"
    }
  },
  plugins: ['oneclick']
}
