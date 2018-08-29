const TavernNFTs = artifacts.require('TavernNFTs');
const Tavern = artifacts.require('Tavern');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('TavernNFTs', function (accounts) {
  beforeEach(async function () {
    this.name = 'LORDLESS Tavern NFT';
    this.symbol = 'Tavern';
    this.TavernNFTs = await TavernNFTs.new(this.name, this.symbol, { from: accounts[0] });
  });

  it('should deploy success', async function () {
    const nane = await this.TavernNFTs.name.call();
    const symbol = await this.TavernNFTs.symbol.call();

    nane.should.be.equal(this.name);
    symbol.should.be.equal(this.symbol);
  });

  it('should mint token to accounts[1]', async function () {
    const _tokenId = 3;
    await this.TavernNFTs.mint(accounts[1], _tokenId);
    const count = await this.TavernNFTs.balanceOf(accounts[1]);
    count.should.be.bignumber.equal(1);
    (await this.TavernNFTs.ownerOf(_tokenId)).should.be.equal(accounts[1]);
  });

  it('tokenId >= 5000 should be revert', async function () {
    const _tokenId = 5000;
    await this.TavernNFTs.mint(accounts[1], _tokenId).should.be.rejectedWith('revert');
  });

  it('batch mint', async function () {
    const tos = [accounts[1], accounts[2], accounts[3], accounts[4]];
    const tokenIds = [6, 7, 8, 9];
    await this.TavernNFTs.batchMint(tos, tokenIds);
    tokenIds.forEach(async (tokenId, i) => {
      (await this.TavernNFTs.ownerOf(tokenId)).should.be.equal(tos[i])
    })
  });

  it('should burn a token', async function () {
    const _tokenId = 3;
    await this.TavernNFTs.mint(accounts[1], _tokenId);
    await this.TavernNFTs.burn(_tokenId);
    await this.TavernNFTs.ownerOf(_tokenId).should.be.rejectedWith('revert');
  });

  it('should set token uri success', async function () {
    const _tokenId = 3;
    const uri = 'testUrl';
    await this.TavernNFTs.mint(accounts[1], _tokenId);
    await this.TavernNFTs.setTokenURI(_tokenId, uri);
    (await this.TavernNFTs.tokenURI(_tokenId)).should.be.equal(uri);
  });

  it('set tavernContract success', async function () {
    this.Tavern = await Tavern.new();
    const tavernContract = this.Tavern.address;
    await this.TavernNFTs.setTavernContract(tavernContract);
    (await this.TavernNFTs.tavernContract()).should.be.equal(tavernContract);
  });

  it('get tavern info', async function () {
    this.Tavern = await Tavern.new();
    await this.TavernNFTs.setTavernContract(this.Tavern.address);
    const _tokenId = 6;
    await this.TavernNFTs.mint(accounts[1], _tokenId);
    this.longitude = 10000;
    this.latitude = 10000;
    this.popularity = 1;
    await this.Tavern.build(_tokenId, this.longitude, this.latitude, this.popularity);

    this.tavern = await this.TavernNFTs.tavern(_tokenId);
    this.tavern[1].should.be.bignumber.equal(this.longitude);
    this.tavern[2].should.be.bignumber.equal(this.latitude);
    this.tavern[3].should.be.bignumber.equal(this.popularity);
    this.tavern[4].should.be.bignumber.equal(0);
  });
});
