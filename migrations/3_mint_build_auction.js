const NFTsCrowdsale = artifacts.require('NFTsCrowdsale');

const fs = require('fs-extra');

module.exports = function (deployer, network, accounts) {
  if(['test', 'coverage'].includes(network)) return;
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

  /* mint and build ldb from tokenId 0 - 39 */

  const data1 = require('../storage/3-1-data');
  const data2 = require('../storage/3-2-data');
  let i = 1;
  for(data of [data1, data2]){
    const tokenIds = Object.keys(data);
    const values = Object.values(data)
    // batch mint NFTs
    const tos = (new Array(values.length)).fill(account0);
    console.log(`**** ${i} batch mint NFTs ****`)
    await LDBNFTs.batchMint(tos, tokenIds, {
      gas: 3712388
    })
    // batch build LDBs 
    console.log(`**** ${i} batch build LDBs  ****`)
    const longitudes = values.map(item => item.longitude);
    const latitudes = values.map(item => item.latitude);
    const popularitys = values.map(item => parseInt(item.popularity));
    await Building.batchBuild(tokenIds, longitudes, latitudes, popularitys, {
      gas: 3212388
    });

    // batch auction
    console.log(`**** ${i} batch new auctions  ****`)
    const _auctionTokenIds = tokenIds.filter(tokenId => data[tokenId].price !== null);
    const _auctionPrices = _auctionTokenIds.map(tokenId => data[tokenId].price.toString());
    const _auctionStartAts = _auctionTokenIds.map(tokenId => data[tokenId].startAt.toString());
    const _auctionEndAts = _auctionTokenIds.map(tokenId => data[tokenId].endAt.toString());
    await NFTsCrowdsale.batchNewAuctions(_auctionPrices, _auctionTokenIds, _auctionStartAts, _auctionEndAts, {
      gas: 3612388
    });
    i++;
  }
}