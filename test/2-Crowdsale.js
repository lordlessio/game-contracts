var LdbNFT = artifacts.require('LdbNFT');
var LdbNFTCrowdsale = artifacts.require('LdbNFTCrowdsale');
const { balanceOf, ether2wei } = require('../helper/etherUtils');
const BigNumber = web3.BigNumber;
require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('LdbNFTCrowdsale', function (accounts) {
  before(async function () {
    // Maximum allowable error
    this.maError = parseInt(web3.toWei(1, 'gwei'));
  });
  beforeEach(async function () {
    this.ldbNFT = await LdbNFT.new('LDB NFT', 'LDB', { from: accounts[0] });
    this.LdbNFTCrowdsale = await LdbNFTCrowdsale.new(this.ldbNFT.address, { from: accounts[0] });
    this.price = 0.5e18;
    this._tokenId = 1;
    this.seller = accounts[0];
    this.buyer = accounts[1];
    await this.ldbNFT.mint(accounts[0], this._tokenId);
    // Set Approval For Crowdsale Contract
    await this.ldbNFT.setApprovalForAll(this.LdbNFTCrowdsale.address, true, { from: accounts[0] });

    await this.LdbNFTCrowdsale.newSale(this.price, this._tokenId, { from: this.seller });
  });

  describe('get method test', function () {
    it('should get order success', async function () {
      const order = await this.LdbNFTCrowdsale.getOrder(this._tokenId);
      // should be seller
      order[0].should.be.equal(accounts[0]);
      // should be price
      order[1].should.be.bignumber.equal(this.price);
      // Todo:should be time
      // should be token_id
      order[3].should.be.bignumber.equal(this._tokenId);
    });
  });

  /**
   * Defray Function Test
   */
  describe('defray test', function () {
    describe('defray: success', function () {
      beforeEach(async function () {
        // defray success
        this.preBalance = (await web3.eth.getBalance(this.seller)).toNumber();
        await this.LdbNFTCrowdsale.defray(this._tokenId, {
          value: this.price,
          from: this.buyer,
        });
      });

      it('shuould change token ownership', async function () {
        // check ownership of _tokenId should be change to buyer
        (await this.ldbNFT.ownerOf(this._tokenId)).should.be.equal(this.buyer);
      });

      it('shuould add price_count ether to seller', async function () {
        const finalCount = (await web3.eth.getBalance(this.seller)).toNumber();
        const computedCount = this.preBalance + this.price;
        // error less than 1gwei
        (finalCount - computedCount).should.be.below(this.maError);
      });
    });
    
    describe('defray:revert or accident', function () {
      it('less ether defray: should revert', async function () {
        const buyer = accounts[1];
        await this.LdbNFTCrowdsale.defray(this._tokenId, {
          value: this.price / 2,
          from: buyer,
        }).should.be.rejectedWith('revert');
      });

      it('defray with defray excess be should return of ', async function () {
        const defrayExcess = 1e18;
        const gasPrice = web3.toWei(1.5, 'gwei');
        const preBalance = (await web3.eth.getBalance(this.buyer)).toNumber();
        const receipt = await this.LdbNFTCrowdsale.defray(this._tokenId, {
          gasPrice,
          value: this.price + defrayExcess,
          from: this.buyer,
        });
        const afterDefrayBalance = (await web3.eth.getBalance(this.buyer)).toNumber();
        const gasCost = receipt.receipt.gasUsed * gasPrice;
        // defrayExcess should be return of
        (afterDefrayBalance - (preBalance - this.price - gasCost)).should.be.below(this.maError);
      });
    });
  });

  describe('withdrawBalance test', function () {
    it('should withdrawBalance success', async function () {
      const preBalance = (await balanceOf(accounts[0])).toNumber();
      const depositCount = ether2wei(1); // ether
      const gasPrice = web3.toWei(1.5, 'gwei');
      
      // send ether
      await this.LdbNFTCrowdsale.sendTransaction({ value: depositCount, from: accounts[1] });
      
      // withdrawBalance
      const receipt = await this.LdbNFTCrowdsale.withdrawBalance({ gasPrice });
      const finalCount = (await balanceOf(accounts[0])).toNumber();
      const gasCost = receipt.receipt.gasUsed * gasPrice;

      // check balance
      const computedCount = depositCount.toNumber() - gasCost;
      const infactCount = finalCount - preBalance;

      (computedCount - infactCount).should.be.below(this.maError);
    });
    it('revert: withdrawBalance with another address', async function () {
      await this.LdbNFTCrowdsale.withdrawBalance({ from: accounts[1] }).should.be.rejectedWith('revert');
    });
  });
});
