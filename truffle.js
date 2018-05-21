var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = process.env.LORDLESS_TEST_MNEMONIC;
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      // gas: 4500000,
    },

    ropsten: {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"),
      network_id: '*' ,// official id of the ropsten network
      gas: 4500000,
      gasPrice: 21000000000
    }
  }
};
