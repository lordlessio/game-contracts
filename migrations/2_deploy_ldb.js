const LdbNFT = artifacts.require('./LdbNFT.sol');

module.exports = async function (deployer, network, accounts) {
  await liveDeploy(deployer, accounts);
};

async function liveDeploy (deployer, accounts) {
  const name = 'LDB NFT';
  const symbol = 'LDB';
  await deployer.deploy(LdbNFT, name, symbol);
}
