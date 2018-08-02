const HDWalletProvider = require('truffle-hdwallet-provider');
const mnemonic = process.env.LORDLESS_TEST_MNEMONIC;
const mnemonicProd = process.env.LORDLESS_PROD_MNEMONIC;

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
      // provider: new HDWalletProvider(mnemonic, 'http://127.0.0.1:8545/'),
      provider: new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/'),
      network_id: '3',
      gasPrice: 2000000000,
    },
    mainnet: {
      provider: new HDWalletProvider(mnemonicProd, 'https://mainnet.infura.io/'),
      network_id: '*',
    },
  },
};
