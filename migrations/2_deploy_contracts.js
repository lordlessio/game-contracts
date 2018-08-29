const TavernNFTs = artifacts.require('TavernNFTs');
const NFTsCrowdsale = artifacts.require('NFTsCrowdsale');
const Tavern = artifacts.require('Tavern');
const Power = artifacts.require('Power');
const fs = require('fs-extra');

module.exports = function (deployer, network, accounts) {
  if(['test', 'coverage'].includes(network)) return;
  this.path = require('path').join(__dirname, `../.deployed/${network}.json`);
  this.config = require('../config')(network);
  deployer.then(async function () {
    await liveDeploy(deployer, network, accounts);
  }).catch(console.log);
};

async function liveDeploy (deployer, network, [ account0 ]) {
  console.log('******** deploy TavernNFTs contract ********');
  const name = 'Tavern NFT';
  const symbol = 'Tavern';
  this.TavernNFTs = await TavernNFTs.new(name, symbol, { from: account0, gas: 3712388 });

  console.log('******** deploy & seting Tavern/Power contract ********');
  const r = await Promise.all([ Tavern.new({}, { gas: 3712388 }), Power.new({}, { gas: 3712388 }) ]);
  this.Tavern = r[0];
  this.Power = r[1];
  await Promise.all([
    this.Tavern.setPowerContract(this.Power.address),
    this.Power.setTavernContract(this.Tavern.address),
  ]);

  console.log('******** set TavernNFTs TavernContract address ********');
  await this.TavernNFTs.setTavernContract(this.Tavern.address)
  console.log('******** deploy & seting NFTsCrowdsale contract ********');
  if (network === 'development' || network === 'coverage') {
    const erc20 = await artifacts.require('LORDLESS_TOKEN').new({},{ gas: 3712388 })
    this.config.erc20Address = erc20.address
  }
  this.NFTsCrowdsale = await NFTsCrowdsale.new(this.TavernNFTs.address, this.config.erc20Address, this.config.eth2erc20, { gas: 3712388 });

  await this.TavernNFTs.setApprovalForAll(this.NFTsCrowdsale.address, true);

  // save to file
  const result = {
    TavernNFTs: {
      address: this.TavernNFTs.address,
      tx: this.TavernNFTs.transactionHash,
      abi: artifacts.require('ITavernNFTs').abi,
    },
    Tavern: {
      address: this.Tavern.address,
      tx: this.Tavern.transactionHash,
      abi: artifacts.require('ITavern').abi,
    },
    Power: {
      address: this.Power.address,
      tx: this.Power.transactionHash,
      abi: artifacts.require('IPower').abi,
    },
    NFTsCrowdsale: {
      address: this.NFTsCrowdsale.address,
      tx: this.NFTsCrowdsale.transactionHash,
      abi: artifacts.require('INFTsCrowdsale').abi,
    },
    createdAt: new Date(),
  };
  await fs.outputJson(this.path, result);
}
