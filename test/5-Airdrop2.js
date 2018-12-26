const Airdrop = artifacts.require('Airdrop_2');
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
    await this.Erc20Token.mint(this.Airdrop.address, this.total);
    await this.Erc20Token.approve(this.Airdrop.address, 1e64);
    
    const spendTokenAddresses = [this.Erc20Token.address];
    const spendTokenCount = [1e18]; // 1 LESS
    const spendEtherCount = 1e17;// 0.1 ether

    const earnTokenAddresses = [this.Erc20Token.address];
    const earnTokenCount = [0]; // 10 LESS
    const earnTokenProbability = [90]; // (0 - 100)
    const earnEtherCount = 1e18;//1 ether
    const earnEtherProbability = 10;

    await this.Airdrop.addAirdrop();
    const airdropIds = await this.Airdrop.getAirdropIds.call();
    this.airdropId = airdropIds[0];
    await this.Airdrop.updateAirdropSpend(this.airdropId, spendTokenAddresses, spendTokenCount, spendEtherCount);
    await this.Airdrop.updateAirdropEarn(this.airdropId, earnTokenAddresses, earnTokenCount, earnTokenProbability, earnEtherCount, earnEtherProbability);

  })
  beforeEach(async function () {
    // this.pre_airdropIds = await this.Airdrop.getAirdropIds.call();
    // this.pre_contract_airdropIds = await this.Airdrop.getAirdropIdsByContractAddress(this.Erc20Token.address);
    // await this.Airdrop.addAirdrop(this.Erc20Token.address, 1000, false);

    // this.after_airdropIds = await this.Airdrop.getAirdropIds.call();
    // this.after_contract_airdropIds = await this.Airdrop.getAirdropIdsByContractAddress.call(this.Erc20Token.address);
  });
  it('addAirdrop success', async function () {
    

    const airdropBase = await this.Airdrop.getAirdropBase.call(this.airdropId)
    const airdropEarn = await this.Airdrop.getAirdropEarn.call(this.airdropId)
    const airdropSpend = await this.Airdrop.getAirdropSpend.call(this.airdropId)

    console.log(airdropBase,'\n---');
    console.log(airdropEarn,'\n---');
    console.log(airdropSpend,'\n---');

    
  });
  it('claim success', async function () {
    // await this.Airdrop.claim(this.airdropId).should.rejectedWith('revert');
    await this.Erc20Token.mint(owner, 100e18);
    await this.Airdrop.start(this.airdropId);
    await web3.eth.sendTransaction({
      from: account1,
      value: 5e18,
      to: this.Airdrop.address
    });
    const airdropSpend = await this.Airdrop.getAirdropSpend.call(this.airdropId)
    console.log(await this.Erc20Token.balanceOf(this.Airdrop.address))
    const log = await this.Airdrop.claim(this.airdropId, {
      value: airdropSpend[2].toNumber()
    });
    console.log(log.logs[0].args);

  })
});
