const LDBNFTs = artifacts.require('LDBNFTs');
const NFTsCrowdsale = artifacts.require('NFTsCrowdsale');
const Building = artifacts.require('Building');
const Power = artifacts.require('Power');
const fs = require('fs-extra');

module.exports = function (deployer, network, accounts) {
  if (network === 'development' || network === 'coverage') return;
  this.path = require('path').join(__dirname, `../.lordless/${network}.json`);
  this.config = require('../config')(network);
  deployer.then(async function () {
    await liveDeploy(deployer, network, accounts);
  }).catch(console.log);
};

async function liveDeploy (deployer, network, [ account0 ]) {
  console.log('******** deploy LDBNFTs contract ********');
  const name = 'LDB NFT';
  const symbol = 'LDB';
  this.LDBNFTs = await LDBNFTs.new(name, symbol, { from: account0 });

  console.log('******** deploy & seting Building/Power contract ********');
  const r = await Promise.all([ Building.new(), Power.new() ]);
  this.Building = r[0];
  this.Power = r[1];
  await Promise.all([
    this.Building.setPowerContract(this.Power.address),
    this.Power.setBuildingContract(this.Building.address),
  ]);

  console.log('******** set LDBNFTs BuildingContract address ********');
  await this.LDBNFTs.setBuildingContract(this.Building.address)

  console.log('******** deploy & seting NFTsCrowdsale contract ********');
  this.NFTsCrowdsale = await NFTsCrowdsale.new(this.LDBNFTs.address, this.config.erc20Address, this.config.eth2erc20);


  // save to file
  const result = {
    LDBNFTs: {
      address: this.LDBNFTs.address,
      abi: artifacts.require('ILDBNFTs').abi,
    },
    Building: {
      address: this.Building.address,
      abi: artifacts.require('IBuilding').abi,
    },
    Power: {
      address: this.Power.address,
      abi: artifacts.require('IPower').abi,
    },
    NFTsCrowdsale: {
      address: this.NFTsCrowdsale.address,
      abi: artifacts.require('INFTsCrowdsale').abi,
    },
    createdAt: new Date(),
  };
  
  await fs.outputJson(this.path, result);
}
