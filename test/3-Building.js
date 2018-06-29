const Building = artifacts.require('Building');
const Influence = artifacts.require('Influence');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

function getInfluence (_reputation, _activity) {
  return _reputation * _activity + parseInt(_reputation);
}

contract('Building', function ([_, owner]) {
  before(async function () {
    this.tokenId = 1;
    this.reputation = 4;
    this.latitude = 10000000000000;
    this.longtitude = 10000000000000;
  });

  beforeEach(async function () {
    this.Building = await Building.new();
    this.Influence = await Influence.new();
    await this.Building.setInfluenceContract(this.Influence.address);
    await this.Influence.setBuildingContract(this.Building.address);

    await this.Building.build(this.tokenId, this.latitude, this.longtitude, this.reputation);
    this.ldb = await this.Building.building(this.tokenId);
  });

  it('set buildingContract & influenceContract success', async function () {
    (await this.Building.getInfluenceContract()).should.be.equal(this.Influence.address);
    (await this.Influence.getBuildingContract()).should.be.equal(this.Building.address);
  });

  it('get a ldb info', async function () {
    this.ldb[1].should.be.bignumber.equal(this.latitude);
    this.ldb[2].should.be.bignumber.equal(this.longtitude);
    this.ldb[3].should.be.bignumber.equal(this.reputation);
    this.ldb[4].should.be.bignumber.equal(0);
  });

  it('activityUpgrade', async function () {
    const activity = 10;
    await this.Building.activityUpgrade(this.tokenId, activity);
    const ldb = await this.Building.building(this.tokenId);
    ldb[4].should.be.bignumber.equal(this.ldb[4].toNumber() + activity);
  });
  it('get ldb reputation', async function () {
    const activity = 20;
    await this.Building.activityUpgrade(this.tokenId, activity);
    const ldb = await this.Building.building(this.tokenId);
    const influence = await this.Building.influenceByToken(this.tokenId);
    influence.should.be.bignumber.equal(getInfluence(ldb[3], ldb[4]));
    // console.log(influence);
  });

  it('ldb isBuilt', async function () {
    (await this.Building.isBuilt(this.tokenId)).should.be.equal(true);
    (await this.Building.isBuilt(2333)).should.be.equal(false);
  });

  it('reputationSetting', async function () {
    const reputation = 1;
    await this.Building.reputationSetting(this.tokenId, reputation);
    const ldb = await this.Building.building(this.tokenId);
    ldb[3].should.be.bignumber.equal(reputation);
  });
});
