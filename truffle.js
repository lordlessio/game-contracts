var HDWalletProvider = require('truffle-hdwallet-provider');
var mnemonic = process.env.LORDLESS_TEST_MNEMONIC;
console.log(mnemonic);
module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // Match any network id
      // gas: 0xfffffffff,
      // gasPrice: 0x01,
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffff,
      gasPrice: 0x01,
    },
    ropsten: {
      provider: new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/'),
      network_id: '3',
    },
    mainnet: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // Match any network id
      provider: new HDWalletProvider(mnemonic, 'http://127.0.0.1:8545/'),
    },
  },
};
