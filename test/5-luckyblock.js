const Luckyblock = artifacts.require('luckyblock');
const Erc20TokenMock = artifacts.require('LORDLESS_TOKEN');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('luckyblock', function ([owner, account1, account2]) {
  before(async function(){
    this.Erc20Token = await Erc20TokenMock.new();
    this.Luckyblock = await Luckyblock.new();
    this.total = 1e22;
    await this.Erc20Token.mint(this.Luckyblock.address, this.total);
    await this.Erc20Token.approve(this.Luckyblock.address, 1e64);
    
    const spendTokenAddresses = [this.Erc20Token.address];
    const spendTokenCount = [1e18]; // 1 LESS
    const spendEtherCount = 1e17;// 0.1 ether

    const earnTokenAddresses = ["0x0000000000000000000000000000000000000000"];
    const earnTokenCount = []; // 10 LESS
    const earnTokenProbability = []; // (0 - 100)
    const earnEtherCount = 1e18;//1 ether
    const earnEtherProbability = 10;

    await this.Luckyblock.addLuckyblock(1);
    const luckyblockIds = await this.Luckyblock.getLuckyblockIds.call();
    this.luckyblockId = luckyblockIds[0];
    await this.Luckyblock.updateLuckyblockSpend(this.luckyblockId, spendTokenAddresses, spendTokenCount, spendEtherCount);
    await this.Luckyblock.updateLuckyblockEarn(this.luckyblockId, earnTokenAddresses, earnTokenCount, earnTokenProbability, earnEtherCount, earnEtherProbability);

  })
  beforeEach(async function () {
    // this.pre_luckyblockIds = await this.Luckyblock.getLuckyblockIds.call();
    // this.pre_contract_luckyblockIds = await this.Luckyblock.getLuckyblockIdsByContractAddress(this.Erc20Token.address);
    // await this.Luckyblock.addLuckyblock(this.Erc20Token.address, 1000, false);

    // this.after_luckyblockIds = await this.Luckyblock.getLuckyblockIds.call();
    // this.after_contract_luckyblockIds = await this.Luckyblock.getLuckyblockIdsByContractAddress.call(this.Erc20Token.address);
  });
  it('addLuckyblock success', async function () {
    

    const luckyblockBase = await this.Luckyblock.getLuckyblockBase.call(this.luckyblockId)
    const luckyblockEarn = await this.Luckyblock.getLuckyblockEarn.call(this.luckyblockId)
    const luckyblockSpend = await this.Luckyblock.getLuckyblockSpend.call(this.luckyblockId)

    // console.log(luckyblockBase,'\n---');
    // console.log(luckyblockEarn,'\n---');
    // console.log(luckyblockSpend,'\n---');

    
  });
  it('play success', async function () {
    // await this.Luckyblock.play(this.luckyblockId).should.rejectedWith('revert');
    await this.Erc20Token.mint(owner, 100e18);
    await this.Luckyblock.start(this.luckyblockId);
    await web3.eth.sendTransaction({
      from: account1,
      value: 5e18,
      to: this.Luckyblock.address
    });
    const luckyblockSpend = await this.Luckyblock.getLuckyblockSpend.call(this.luckyblockId)
    await this.Luckyblock.play(this.luckyblockId, {
      value: luckyblockSpend[2].toNumber()
    });
  })

  it('withdraw eth', async function () {
    // withdraw eth
     
     const balance1 = await web3.eth.getBalance(account2)
     await this.Luckyblock.withdrawEth(account2, 1e17)
     const _balance1 = await web3.eth.getBalance(account2)
     _balance1.toNumber().should.be.equal(balance1.toNumber() + 1e17)

    // withdraw all eth
     const balanceAll = await web3.eth.getBalance(this.Luckyblock.address)
     const balance2 = await web3.eth.getBalance(account2)
     await this.Luckyblock.withdrawEth(account2, 0)
     const _balance2 = await web3.eth.getBalance(account2)
     _balance2.toNumber().should.be.equal(balance2.toNumber() + balanceAll.toNumber())
  })

  it('withdraw erc20', async function () {
    // withdraw erc20
     
     const balance1 = await this.Erc20Token.balanceOf(account2)
     await this.Luckyblock.withdrawToken(this.Erc20Token.address, account2, 10e18)
     const _balance1 = await this.Erc20Token.balanceOf(account2)
     _balance1.toNumber().should.be.equal(balance1.toNumber() + 10e18)

    // // withdraw all erc20
     const balanceAll = await this.Erc20Token.balanceOf(this.Luckyblock.address)
     const balance2 = await this.Erc20Token.balanceOf(account2)
     await this.Luckyblock.withdrawToken(this.Erc20Token.address, account2, 0)
     const _balance2 = await this.Erc20Token.balanceOf(account2)
     _balance2.toNumber().should.be.equal(balance2.toNumber() + balanceAll.toNumber())
  })
});
