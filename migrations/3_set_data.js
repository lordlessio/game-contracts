const LDBNFTs = artifacts.require('LDBNFTs');
// const LdbNFTCrowdsale = artifacts.require('NFTsCrowdsale');

// const Building = artifacts.require('Building');
// const Influence = artifacts.require('Influence');

// const fs = require('fs');
// const dbPath = require('path').join(require('os').homedir(), '.lordless/dev.conf');
module.exports = function (deployer, network, accounts) {
  deployer.then(async function () {
    await liveDeploy(deployer, accounts);
  }).catch(console.log);
};

async function liveDeploy (deployer, accounts) {
  // LDBNFTs.deployed().then(console.log).catch(console.log);
  // console.log('a.address', a.address);
}
