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
  // const name = 'LDB NFT';
  // const symbol = 'LDB';

  // console.log('******** deploy LDBNFTs contract ********');
  // this.LDBNFTs = await LDBNFTs.new(name, symbol, { from: accounts[0] });
  // console.log('this.LDBNFTs', this.LDBNFTs.address);
  // console.log('******** deploy Building contract ********');
  // this.building = await Building.new();
  // this.influence = await Influence.new();
  // this.building.setInfluenceContract(this.influence.address);

  // // deploy LdbNFTs contract
  // console.log(4);
  // // eth 2 less
  // this.eth2erc20 = 41666;
  // this.ldbNFTCrowdsale = await LdbNFTCrowdsale.new(this.ldbNFT.address, this.erc20Token.address, this.eth2erc20);

  // console.log(5);
  // await this.erc20Token.mint(accounts[0], 5e27);
  // console.log(6, accounts[1]);
  // await this.erc20Token.mint(accounts[1], 5e27);
  // console.log(7);
  // // await this.ldbNFT.setApprovalForAll(this.ldbNFTCrowdsale.address, true, { from: accounts[0] });
  // await this.ldbNFT.setApprovalForAll(this.ldbNFTCrowdsale.address, true, { from: accounts[1] });
  // await this.erc20Token.approve(this.ldbNFTCrowdsale.address, 1e27, { from: accounts[0] });
  // await this.erc20Token.approve(this.ldbNFTCrowdsale.address, 1e27, { from: accounts[1] });

  // /**
  //  * 测试数据
  //  */
  // const dataTime = Math.floor(new Date().getTime() / 1000);
  // await this.ldbNFT.mint(accounts[1], 0);
  // await this.Building.build(0, 12150160200000, 31239878000000, 5);
  // await this.ldbNFTCrowdsale.newAuction('68880000000000000000', 0, dataTime + 3600 * 3, { from: accounts[1] });

  // await this.ldbNFT.mint(accounts[1], 1);
  // await this.Building.build(1, 12144529600000, 31223510000000, 4);
  // await this.ldbNFTCrowdsale.newAuction('58880000000000000000', 1, dataTime + 3600 * 2, { from: accounts[1] });

  // await this.ldbNFT.mint(accounts[1], 2);
  // await this.Building.build(2, 12148954270000, 31239038800000, 3);
  // await this.ldbNFTCrowdsale.newAuction('48880000000000000000', 2, dataTime + 3600 * 1, { from: accounts[1] });

  // const content = {
  //   ldbNFT: {
  //     address: this.ldbNFT.address,
  //     abi: this.ldbNFT.abi,
  //   },
  //   ldbNFTCrowdsale: {
  //     address: this.ldbNFTCrowdsale.address,
  //     abi: this.ldbNFTCrowdsale.abi,
  //   },
  //   erc20: {
  //     address: this.erc20Token.address,
  //     abi: this.erc20Token.abi,
  //   },
  //   building: {
  //     address: this.Building.address,
  //     abi: this.Building.abi,
  //   },
  // };

  // fs.writeFileSync(dbPath, JSON.stringify(content));
}
