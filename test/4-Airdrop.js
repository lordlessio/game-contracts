const Airdrop = artifacts.require('Airdrop');
const Erc20TokenMock = artifacts.require('LORDLESS_TOKEN');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('airdrop', function ([owner, account1, account2]) {
  before(async function(){
    this.Erc20Token = await Erc20TokenMock.new();
    this.Airdrop = await Airdrop.new();
    this.total = 1e27;
    this.Erc20Token.mint(this.Airdrop.address, this.total);
    // this.endAt = 2398377600 // 2046.1.1
  })
  beforeEach(async function () {
    this.pre_airdropIds = await this.Airdrop.getAirdropIds.call();
    this.pre_contract_airdropIds = await this.Airdrop.getAirdropIdsByContractAddress(this.Erc20Token.address);
    await this.Airdrop.addAirdrop(this.Erc20Token.address, 1000, false);

    this.after_airdropIds = await this.Airdrop.getAirdropIds.call();
    this.after_contract_airdropIds = await this.Airdrop.getAirdropIdsByContractAddress.call(this.Erc20Token.address);
  });
  it('addAirdrop success', async function () {
    (this.after_airdropIds.length - this.pre_airdropIds.length).should.be.equal(1);
    (this.after_contract_airdropIds.length - this.pre_contract_airdropIds.length).should.be.equal(1);
  });
  it('claim success', async function () {
    const airdropId = this.after_airdropIds[0];
    const airdrop = await this.Airdrop.getAirdrop.call(airdropId);
    // const airdropId = this.after_contract_airdropIds[0];
    await this.Airdrop.claim(airdropId, { from: account1 });
    (await this.Erc20Token.balanceOf.call(account1)).should.be.bignumber.equal(airdrop[1]);
    (await this.Airdrop.tokenTotalClaim.call(this.Erc20Token.address)).should.be.bignumber.equal(airdrop[1])
  });

  it('if airdrop is collected', async function () {
    const airdropId = this.after_airdropIds[0];
    const airdropId1 = this.after_airdropIds[1];
    (await this.Airdrop.isCollected(account1, airdropId)).should.be.equal(true);
    (await this.Airdrop.isCollected(account2, airdropId)).should.be.equal(false);
    (await this.Airdrop.isCollected(account2, airdropId1)).should.be.equal(false);
  });

  it('claim fail', async function () {
    const airdropId = this.after_airdropIds[0];
    await this.Airdrop.claim(airdropId, { from: account1 }).should.be.rejectedWith('revert');
  });

  it('verify user', async function () {
    // const airdropId = this.after_airdropIds[0];
    await this.Airdrop.verifyUser('膝盖', { from: account1, value: 1e18 });
    const user = await this.Airdrop.getUser.call(account1);
    (await web3.eth.getBalance(this.Airdrop.address)).should.be.bignumber.equal(2e16);
  });

  it('needed verified user', async function () {
    // const airdropId = this.after_airdropIds[0];
    this.Airdrop2 = await Airdrop.new();
    this.Airdrop2.addAirdrop(this.Erc20Token.address, 2000, true);
    const airdropId = (await this.Airdrop2.getAirdropIds.call())[0];
    
    await this.Airdrop2.claim(airdropId, { from: account2 }).should.be.rejectedWith('revert');
    await this.Airdrop2.verifyUser('account2', { from: account2, value: 1e18 });
    this.Erc20Token.mint(this.Airdrop2.address, this.total);
    await this.Airdrop2.claim(airdropId, { from: account2 })

    // (await web3.eth.getBalance(this.Airdrop.address)).should.be.bignumber.equal(2e16);
  });

  it('update verifyFee success', async function () {
    // const airdropId = this.after_airdropIds[0];
    const verifyFee = 3e16
    await this.Airdrop.updateVeifyFee(verifyFee);
    (await this.Airdrop.verifyFee.call()).should.be.bignumber.equal(verifyFee);
  });

  it('withdrawToken', async function () {
    const balance = await this.Erc20Token.balanceOf.call(this.Airdrop.address);
    await this.Airdrop.withdrawToken(this.Erc20Token.address, owner);
    (await this.Erc20Token.balanceOf.call(owner)).should.be.bignumber.equal(balance);
  });

  it('withdrawEth', async function () {
    const balance = (await web3.eth.getBalance(this.Airdrop.address))
    const balance2 = (await web3.eth.getBalance(account2))
    await this.Airdrop.withdrawEth(account2);
    (await web3.eth.getBalance(account2)).should.be.bignumber.equal(balance.toNumber() + balance2.toNumber());
  });

});
