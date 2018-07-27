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
    this.longitude = 10000000000000;
    this.longitudeNegative = false;
    this.latitude = 10000000000000;
    this.latitudeNegative = true;
  });

  beforeEach(async function () {
    this.Building = await Building.new();
    this.Influence = await Influence.new();
    await this.Building.setInfluenceContract(this.Influence.address);
    await this.Influence.setBuildingContract(this.Building.address);

    const { logs } = await this.Building.build(
      this.tokenId,
      this.longitude,
      this.longitudeNegative,
      this.latitude,
      this.latitudeNegative,
      this.reputation
    );
    this.logs = logs;
    this.ldb = await this.Building.building(this.tokenId);
  });
 
  it('event Build', async function () {
    this.logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    this.logs[0].args.longitude.should.be.bignumber.equal(this.longitude);
    this.logs[0].args.longitudeNegative.should.be.equal(this.longitudeNegative);
    this.logs[0].args.latitude.should.be.bignumber.equal(this.latitude);
    this.logs[0].args.latitudeNegative.should.be.equal(this.latitudeNegative);
    this.logs[0].args.reputation.should.be.bignumber.equal(this.reputation);
  });

  it('set buildingContract & influenceContract success', async function () {
    (await this.Building.getInfluenceContract()).should.be.equal(this.Influence.address);
    (await this.Influence.getBuildingContract()).should.be.equal(this.Building.address);
  });

  it('get a ldb info', async function () {
    this.ldb[1].should.be.bignumber.equal(this.longitude);
    this.ldb[2].should.be.equal(this.longitudeNegative);
    this.ldb[3].should.be.bignumber.equal(this.latitude);
    this.ldb[4].should.be.equal(this.latitudeNegative);
    this.ldb[5].should.be.bignumber.equal(this.reputation);
    this.ldb[6].should.be.bignumber.equal(0);
  });

  it('activityUpgrade', async function () {
    const deltaActivity = 10;
    const oldb = await this.Building.building(this.tokenId);
    const oActivity = oldb[6].toNumber();
    const { logs } = await this.Building.activityUpgrade(this.tokenId, deltaActivity);
    const ldb = await this.Building.building(this.tokenId);
    ldb[6].should.be.bignumber.equal(oActivity + deltaActivity);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oActivity.should.be.bignumber.equal(oActivity);
    logs[0].args.newActivity.should.be.bignumber.equal(oActivity + deltaActivity);
  });
  it('get ldb reputation', async function () {
    const activity = 20;
    await this.Building.activityUpgrade(this.tokenId, activity);
    const ldb = await this.Building.building(this.tokenId);
    const influence = await this.Building.influenceByToken(this.tokenId);
    influence.should.be.bignumber.equal(getInfluence(ldb[5], ldb[6]));
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
    ldb[5].should.be.bignumber.equal(reputation);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oReputation.should.be.bignumber.equal(oldb[5]);
    logs[0].args.newReputation.should.be.bignumber.equal(ldb[5]);
  });

  describe('multi*', async function () {
    beforeEach(async function () {
      this.tokenIds = [6, 7, 8, 9];
      const longitudes = [1012345678901236, 1012345678901237, 1012345678901238, 1012345678901239];
      const longitudesNegative = [false, false, true, true];
      const latitudes = [1312345678901236, 1312345678901237, 1312345678901238, 1312345678901239];
      const latitudesNegative = [true, true, false, false];
      const reputations = [1, 2, 3, 4];
      await this.Building.multiBuild(
        this.tokenIds, longitudes, longitudesNegative, latitudes, latitudesNegative, reputations
      );
      this.oActivities = await Promise.all(this.tokenIds.map(k =>
        this.Building.building(k).then(b => b[6].toNumber())
      ));
    });

    it('multiActivityUpgrade', async function () {
      const deltaActivities = [600, 700, 800, 900];
      await this.Building.multiActivityUpgrade(this.tokenIds, deltaActivities);
      const activities = await Promise.all(this.tokenIds.map(k =>
        this.Building.building(k).then(b => b[6].toNumber())
      ));
      this.oActivities.forEach((item, i) => {
        activities[i].should.be.equal(this.oActivities[i] + deltaActivities[i]);
      });
    });
  
    it('multiReputationSetting', async function () {
      const newReputations = [4, 3, 2, 1];
      await this.Building.multiReputationSetting(this.tokenIds, newReputations);
      const reputations = await Promise.all(this.tokenIds.map(k =>
        this.Building.building(k).then(b => b[5].toNumber())
      ));
      reputations.forEach((item, i) => {
        reputations[i].should.be.equal(newReputations[i]);
      });
    });
  });
});
