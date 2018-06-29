const LDBNFTs = artifacts.require('LDBNFTs');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('LDBNFTs', function (accounts) {
  beforeEach(async function () {
    this.name = 'LORDLESS Building NFT';
    this.symbol = 'LDB';
    this.LDBNFTs = await LDBNFTs.new(this.name, this.symbol, { from: accounts[0] });
  });

  it('should deploy success', async function () {
    const nane = await this.LDBNFTs.name.call();
    const symbol = await this.LDBNFTs.symbol.call();

    nane.should.be.equal(this.name);
    symbol.should.be.equal(this.symbol);
  });

  it('should mint token to accounts[1]', async function () {
    const _tokenId = 3;
    await this.LDBNFTs.mint(accounts[1], _tokenId);
    const count = await this.LDBNFTs.balanceOf(accounts[1]);
    count.should.be.bignumber.equal(1);
    (await this.LDBNFTs.ownerOf(_tokenId)).should.be.equal(accounts[1]);
  });

  it('should burn a token', async function () {
    const _tokenId = 3;
    await this.LDBNFTs.mint(accounts[1], _tokenId);
    await this.LDBNFTs.burn(_tokenId);
    await this.LDBNFTs.ownerOf(_tokenId).should.be.rejectedWith('revert');
  });

  it('should set token uri success', async function () {
    const _tokenId = 3;
    const uri = 'testUrl';
    await this.LDBNFTs.mint(accounts[1], _tokenId);
    await this.LDBNFTs.setTokenURI(_tokenId, uri);
    (await this.LDBNFTs.tokenURI(_tokenId)).should.be.equal(uri);
  });
});
