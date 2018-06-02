var LdbNFT = artifacts.require('LdbNFT');
const BigNumber = web3.BigNumber;
require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('LdbNFT', function (accounts) {
  beforeEach(async function () {
    this.ldbNFT = await LdbNFT.new('LDB NFT', 'LDB', { from: accounts[0] });
  });

  describe('LdbNFT basic test', function () {
    it('should set title and name when deployed', async function () {
      const nane = await this.ldbNFT.name.call();
      const symbol = await this.ldbNFT.symbol.call();
  
      nane.should.be.equal('LDB NFT');
      symbol.should.be.equal('LDB');
    });

    it('should throw revert when not mint by CLEVEL account', async function () {
      await this.ldbNFT.mint(accounts[0], 1, { from: accounts[1] }).should.be.rejectedWith('revert');
    });
    
    it('should mint token to accounts[1]', async function () {
      await this.ldbNFT.mint(accounts[1], 2);
      const count = await this.ldbNFT.balanceOf(accounts[1]);
      count.should.be.bignumber.equal(1);
    });
  });
});
