const LdbNFT = artifacts.require('./LdbNFT.sol');
const fs = require('fs');
const dbPath = require('path').join(require('os').homedir(), '.lordless/dev.conf');
module.exports = async function (deployer, network, accounts) {
  await liveDeploy(deployer, accounts);
};

async function liveDeploy (deployer, accounts) {
  const name = 'LDB NFT';
  const symbol = 'LDB';
  // await deployer.deploy(LdbNFT, name, symbol);
  
  this.ldbNFT = await LdbNFT.new(name, symbol, { from: accounts[0] });
  const content = {
    address: this.ldbNFT.address,
    abi: this.ldbNFT.abi,
  };
  fs.writeFileSync(dbPath, JSON.stringify(content));
}