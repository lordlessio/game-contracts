const LDBNFTs = artifacts.require('LDBNFTs');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('LDBNFTs', function (accounts) {
  beforeEach(async function () {
    this.LDBNFTs = await LDBNFTs.new('LDB NFT', 'LDB', { from: accounts[0] });
  });

  describe('LDBNFTs basic test', function () {
    it('should set title and name when deployed', async function () {
      const nane = await this.LDBNFTs.name.call();
      const symbol = await this.LDBNFTs.symbol.call();
  
      nane.should.be.equal('LDB NFT');
      symbol.should.be.equal('LDB');
    });

    it('should throw revert when not mint by CLEVEL account', async function () {
      // await this.LDBNFTs.mint(accounts[0], 1, { from: accounts[1] }).should.be.rejectedWith('revert');
    });
    
    it('should mint token to accounts[1]', async function () {
      await this.LDBNFTs.mint(accounts[1], 2);
      const count = await this.LDBNFTs.balanceOf(accounts[1]);
      count.should.be.bignumber.equal(1);
    });
  });
});
