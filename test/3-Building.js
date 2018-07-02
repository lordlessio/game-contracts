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
    this.longitude = 10000000000000;
  });

  beforeEach(async function () {
    this.Building = await Building.new();
    this.Influence = await Influence.new();
    await this.Building.setInfluenceContract(this.Influence.address);
    await this.Influence.setBuildingContract(this.Building.address);

    const { logs } = await this.Building.build(this.tokenId, this.latitude, this.longitude, this.reputation);
    this.logs = logs;
    this.ldb = await this.Building.building(this.tokenId);
  });
 
  it('event Build', async function () {
    this.logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    this.logs[0].args.latitude.should.be.bignumber.equal(this.latitude);
    this.logs[0].args.longitude.should.be.bignumber.equal(this.longitude);
    this.logs[0].args.reputation.should.be.bignumber.equal(this.reputation);
  });

  it('set buildingContract & influenceContract success', async function () {
    (await this.Building.getInfluenceContract()).should.be.equal(this.Influence.address);
    (await this.Influence.getBuildingContract()).should.be.equal(this.Building.address);
  });

  it('get a ldb info', async function () {
    this.ldb[1].should.be.bignumber.equal(this.latitude);
    this.ldb[2].should.be.bignumber.equal(this.longitude);
    this.ldb[3].should.be.bignumber.equal(this.reputation);
    this.ldb[4].should.be.bignumber.equal(0);
  });

  it('activityUpgrade', async function () {
    const activity = 10;
    const oldb = await this.Building.building(this.tokenId);
    const { logs } = await this.Building.activityUpgrade(this.tokenId, activity);
    const ldb = await this.Building.building(this.tokenId);
    ldb[4].should.be.bignumber.equal(this.ldb[4].toNumber() + activity);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oActivity.should.be.bignumber.equal(oldb[4]);
    logs[0].args.newActivity.should.be.bignumber.equal(oldb[4] + activity);
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
    const oldb = await this.Building.building(this.tokenId);
    const { logs } = await this.Building.reputationSetting(this.tokenId, reputation);
    const ldb = await this.Building.building(this.tokenId);
    ldb[3].should.be.bignumber.equal(reputation);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oReputation.should.be.bignumber.equal(oldb[3]);
    logs[0].args.newReputation.should.be.bignumber.equal(ldb[3]);
  });
});
