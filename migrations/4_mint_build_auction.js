const NFTsCrowdsale = artifacts.require('NFTsCrowdsale');

const fs = require('fs-extra');

module.exports = function (deployer, network, accounts) {
  this.path = require('path').join(__dirname, `../.deployed/${network}.json`);
  this.config = require('../config')(network);
  this.contracts = require(`../.deployed/${network}.json`);
  deployer.then(async function () {
    await liveDeploy(deployer, network, accounts);
  }).catch(console.log);
};

async function liveDeploy(deployer, network, [account0]) {
  // get deployed contract 
  const LDBNFTs = await artifacts.require('LDBNFTs').at(contracts['LDBNFTs'].address);
  const Building = await artifacts.require('Building').at(contracts['Building'].address);
  const NFTsCrowdsale = await artifacts.require('NFTsCrowdsale').at(contracts['NFTsCrowdsale'].address);


  /* mint and build ldb from tokenId 0 - 20 */

  const data = require('../storage/4-data');

  const tokenIds = Object.keys(data);
  const values = Object.values(data)
  // batch mint NFTs
  const tos = (new Array(values.length)).fill(account0);
  console.log('1-------------')
  await LDBNFTs.batchMint(tos, tokenIds, {
    gas: 3712388
  })
  // batch build LDBs 
  console.log('2-------------')
  const longitudes = values.map(item => item.longitude);
  const latitudes = values.map(item => item.latitude);
  const popularitys = values.map(item => item.popularity);
  await Building.batchBuild(tokenIds, longitudes, latitudes, popularitys, {
    gas: 2712388
  });

  // batch auction
  const _auctionTokenIds = tokenIds.filter(tokenId => data[tokenId].price !== null);
  const _auctionPrices = _auctionTokenIds.map(tokenId => data[tokenId].price);
  const _auctionEndAts = _auctionTokenIds.map(tokenId => data[tokenId].endAt);
  console.log('3-------------')
  await NFTsCrowdsale.batchNewAuctions(_auctionPrices, _auctionTokenIds, _auctionEndAts, {
    gas: 5012388
  });
}