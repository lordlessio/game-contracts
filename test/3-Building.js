const Building = artifacts.require('Building');
const Power = artifacts.require('Power');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

function getInfluence (_popularity, _activeness) {
  return _popularity * _activeness + parseInt(_popularity);
}

contract('Building', function ([_, owner]) {
  before(async function () {
    this.tokenId = 1;
    this.popularity = 4;
    this.longitude = -10000000000000;
    this.latitude = 10000000000000;
  });

  beforeEach(async function () {
    this.Building = await Building.new();
    this.Power = await Power.new();
    await this.Building.setPowerContract(this.Power.address);
    await this.Power.setBuildingContract(this.Building.address);

    const { logs } = await this.Building.build(
      this.tokenId,
      this.longitude,
      this.latitude,
      this.popularity
    );
    this.logs = logs;
    this.ldb = await this.Building.building(this.tokenId);
  });
  
  it('error longitude & latitude should be revert ', async function () {
    const errorLongitude = 123456789123456789;
    const errorLatitude = 123456789123456789;
    
    await this.Building.build(
      100,
      errorLongitude,
      this.latitude,
      this.popularity
    ).should.be.rejectedWith('revert');

    await this.Building.build(
      200,
      this.longitude,
      errorLatitude,
      this.popularity
    ).should.be.rejectedWith('revert');
  });

  it('event Build', async function () {
    this.logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    this.logs[0].args.longitude.should.be.bignumber.equal(this.longitude);
    this.logs[0].args.latitude.should.be.bignumber.equal(this.latitude);
    this.logs[0].args.popularity.should.be.bignumber.equal(this.popularity);
  });

  it('set buildingContract & powerContract success', async function () {
    (await this.Building.powerContract()).should.be.equal(this.Power.address);
    (await this.Power.buildingContract()).should.be.equal(this.Building.address);
  });

  it('get a ldb info', async function () {
    this.ldb[1].should.be.bignumber.equal(this.longitude);
    this.ldb[2].should.be.bignumber.equal(this.latitude);
    this.ldb[3].should.be.bignumber.equal(this.popularity);
    this.ldb[4].should.be.bignumber.equal(0);
  });

  it('activenessUpgrade', async function () {
    const deltaActiveness = 10;
    const oldb = await this.Building.building(this.tokenId);
    const oActiveness = oldb[4].toNumber();
    const { logs } = await this.Building.activenessUpgrade(this.tokenId, deltaActiveness);
    const ldb = await this.Building.building(this.tokenId);
    ldb[4].should.be.bignumber.equal(oActiveness + deltaActiveness);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oActiveness.should.be.bignumber.equal(oActiveness);
    logs[0].args.newActiveness.should.be.bignumber.equal(oActiveness + deltaActiveness);
  });
  it('get ldb influence', async function () {
    const activeness = 20;
    await this.Building.activenessUpgrade(this.tokenId, activeness);
    const ldb = await this.Building.building(this.tokenId);
    const influence = await this.Building.influenceByToken(this.tokenId);
    influence.should.be.bignumber.equal(getInfluence(ldb[3], ldb[4]));
    // console.log(influence);
  });

  it('get ldb level', async function () {
    const deltaActiveness = 100;
    await this.Building.activenessUpgrade(this.tokenId, deltaActiveness);
    const ldb = await this.Building.building(this.tokenId);
    const activeness = ldb[4];
    const levelShouldBe = parseInt(Math.sqrt(activeness / 10 * 108 * 108) / 108 + 1);
    (await this.Building.levelByToken(this.tokenId)).should.bignumber.equal(levelShouldBe);
  });

  it('get weightsApportion', async function () {
    const userLevel = 10;
    const lordLevel = 20;
    const userWeightsApportionShouleBe = 2000 + 6000 * userLevel / (userLevel + lordLevel);
    (await this.Building.weightsApportion(userLevel, lordLevel))
      .should.be.bignumber.equal(userWeightsApportionShouleBe);
  });
  
  it('ldb isBuilt', async function () {
    (await this.Building.isBuilt(this.tokenId)).should.be.equal(true);
    (await this.Building.isBuilt(2333)).should.be.equal(false);
  });

  it('popularitySetting', async function () {
    const popularity = 1;
    const oldb = await this.Building.building(this.tokenId);
    const { logs } = await this.Building.popularitySetting(this.tokenId, popularity);
    const ldb = await this.Building.building(this.tokenId);
    ldb[3].should.be.bignumber.equal(popularity);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oPopularity.should.be.bignumber.equal(oldb[3]);
    logs[0].args.newPopularity.should.be.bignumber.equal(ldb[3]);
  });

  describe('batch*', async function () {
    beforeEach(async function () {
      this.tokenIds = [6, 7, 8, 9];
      const longitudes = [-1012345678901236, 1012345678901237, 1012345678901238, 1012345678901239];
      const latitudes = [1312345678901236, -1312345678901237, 1312345678901238, 1312345678901239];
      const popularitys = [1, 2, 3, 4];
      await this.Building.batchBuild(
        this.tokenIds, longitudes, latitudes, popularitys
      );
      this.oActiveness = await Promise.all(this.tokenIds.map(k =>
        this.Building.building(k).then(b => b[4].toNumber())
      ));
    });

    it('batchActivenessUpgrade', async function () {
      const deltaActiveness = [600, 700, 800, 900];
      await this.Building.batchActivenessUpgrade(this.tokenIds, deltaActiveness);
      const activeness = await Promise.all(this.tokenIds.map(k =>
        this.Building.building(k).then(b => b[4].toNumber())
      ));
      this.oActiveness.forEach((item, i) => {
        activeness[i].should.be.equal(this.oActiveness[i] + deltaActiveness[i]);
      });
    });
  
    it('batchPopularitySetting', async function () {
      const newPopularitys = [4, 3, 2, 1];
      await this.Building.batchPopularitySetting(this.tokenIds, newPopularitys);
      const popularitys = await Promise.all(this.tokenIds.map(k =>
        this.Building.building(k).then(b => b[3].toNumber())
      ));
      popularitys.forEach((item, i) => {
        popularitys[i].should.be.equal(newPopularitys[i]);
      });
    });
  });
});
