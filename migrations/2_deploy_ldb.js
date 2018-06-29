const LdbNFT = artifacts.require('LDBNFTs');
const LdbNFTCrowdsale = artifacts.require('NFTsCrowdsale');
const Erc20 = artifacts.require('LORDLESS_TOKEN');

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
  this.erc20Token = await Erc20.new();
  this.eth2erc20 = 41666;
  this.ldbNFTCrowdsale = await LdbNFTCrowdsale.new(this.ldbNFT.address, this.erc20Token.address, this.eth2erc20);

  await this.erc20Token.mint(accounts[0], 5e27);
  await this.erc20Token.mint(accounts[1], 5e27);

  // await this.ldbNFT.setApprovalForAll(this.ldbNFTCrowdsale.address, true, { from: accounts[0] });
  // await this.erc20Token.approve(this.ldbNFTCrowdsale.address, 1e27, { from: accounts[0] });

  const content = {
    ldbNFT: {
      address: this.ldbNFT.address,
      abi: this.ldbNFT.abi,
    },
    ldbNFTCrowdsale: {
      address: this.ldbNFTCrowdsale.address,
      abi: this.ldbNFTCrowdsale.abi,
    },
    erc20: {
      address: this.erc20Token.address,
      abi: this.erc20Token.abi,
    }
  };

  fs.writeFileSync(dbPath, JSON.stringify(content));
}