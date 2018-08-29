const Tavern = artifacts.require('Tavern');
const Power = artifacts.require('Power');
const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

function getInfluence (_popularity, _activeness) {
  return _popularity * _activeness + parseInt(_popularity);
}

contract('Tavern', function ([_, owner]) {
  before(async function () {
    this.tokenId = 1;
    this.popularity = 4;
    this.longitude = -10000000000000;
    this.latitude = 10000000000000;
  });

  beforeEach(async function () {
    this.Tavern = await Tavern.new();
    this.Power = await Power.new();
    await this.Tavern.setPowerContract(this.Power.address);
    await this.Power.setTavernContract(this.Tavern.address);

    const { logs } = await this.Tavern.build(
      this.tokenId,
      this.longitude,
      this.latitude,
      this.popularity
    );
    this.logs = logs;
    this.tavern = await this.Tavern.tavern.call(this.tokenId);
  });
  
  it('error longitude & latitude should be revert ', async function () {
    const errorLongitude = -12345678901234567890;
    const errorLatitude = 12345678910234567890;
    
    await this.Tavern.build(
      100,
      errorLongitude,
      this.latitude,
      this.popularity
    ).should.be.rejectedWith('revert');

    await this.Tavern.build(
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

  it('set tavernContract & powerContract success', async function () {
    (await this.Tavern.powerContract()).should.be.equal(this.Power.address);
    (await this.Power.tavernContract()).should.be.equal(this.Tavern.address);
  });

  it('get a tavern info', async function () {
    this.tavern[1].should.be.bignumber.equal(this.longitude);
    this.tavern[2].should.be.bignumber.equal(this.latitude);
    this.tavern[3].should.be.bignumber.equal(this.popularity);
    this.tavern[4].should.be.bignumber.equal(0);
  });

  it('activenessUpgrade', async function () {
    const deltaActiveness = 10;
    const otavern = await this.Tavern.tavern.call(this.tokenId);
    const oActiveness = otavern[4].toNumber();
    const { logs } = await this.Tavern.activenessUpgrade(this.tokenId, deltaActiveness);
    const tavern = await this.Tavern.tavern.call(this.tokenId);
    tavern[4].should.be.bignumber.equal(oActiveness + deltaActiveness);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oActiveness.should.be.bignumber.equal(oActiveness);
    logs[0].args.newActiveness.should.be.bignumber.equal(oActiveness + deltaActiveness);
  });
  it('get tavern influence', async function () {
    const activeness = 20;
    await this.Tavern.activenessUpgrade(this.tokenId, activeness);
    const tavern = await this.Tavern.tavern.call(this.tokenId);
    const influence = await this.Tavern.influenceByToken.call(this.tokenId);
    influence.should.be.bignumber.equal(getInfluence(tavern[3], tavern[4]));
    // console.log(influence);
  });

  it('get tavern level', async function () {
    const deltaActiveness = 100;
    await this.Tavern.activenessUpgrade(this.tokenId, deltaActiveness);
    const tavern = await this.Tavern.tavern.call(this.tokenId);
    const activeness = tavern[4];
    const levelShouldBe = parseInt(Math.sqrt(activeness / 10 * 108 * 108) / 108 + 1);
    (await this.Tavern.levelByToken.call(this.tokenId)).should.bignumber.equal(levelShouldBe);
  });

  it('get weightsApportion', async function () {
    const userLevel = 10;
    const lordLevel = 20;
    const userWeightsApportionShouleBe = 2000 + 6000 * userLevel / (userLevel + lordLevel);
    (await this.Tavern.weightsApportion.call(userLevel, lordLevel))
      .should.be.bignumber.equal(userWeightsApportionShouleBe);
  });
  
  it('tavern isBuilt', async function () {
    (await this.Tavern.isBuilt.call(this.tokenId)).should.be.equal(true);
    (await this.Tavern.isBuilt.call(2333)).should.be.equal(false);
  });

  it('popularitySetting', async function () {
    const popularity = 1;
    const otavern = await this.Tavern.tavern.call(this.tokenId);
    const { logs } = await this.Tavern.popularitySetting(this.tokenId, popularity);
    const tavern = await this.Tavern.tavern.call(this.tokenId);
    tavern[3].should.be.bignumber.equal(popularity);

    logs[0].args.tokenId.should.be.bignumber.equal(this.tokenId);
    logs[0].args.oPopularity.should.be.bignumber.equal(otavern[3]);
    logs[0].args.newPopularity.should.be.bignumber.equal(tavern[3]);
  });

  describe('batch*', async function () {
    beforeEach(async function () {
      this.tokenIds = [6, 7, 8, 9];
      const longitudes = [-1012345678901236, 1012345678901237, 1012345678901238, 1012345678901239];
      const latitudes = [1312345678901236, -1312345678901237, 1312345678901238, 1312345678901239];
      const popularitys = [1, 2, 3, 4];
      await this.Tavern.batchBuild(
        this.tokenIds, longitudes, latitudes, popularitys
      );
      this.oActiveness = await Promise.all(this.tokenIds.map(k =>
        this.Tavern.tavern.call(k).then(b => b[4].toNumber())
      ));
    });

    it('batchActivenessUpgrade', async function () {
      const deltaActiveness = [600, 700, 800, 900];
      await this.Tavern.batchActivenessUpgrade(this.tokenIds, deltaActiveness);
      const activeness = await Promise.all(this.tokenIds.map(k =>
        this.Tavern.tavern.call(k).then(b => b[4].toNumber())
      ));
      this.oActiveness.forEach((item, i) => {
        activeness[i].should.be.equal(this.oActiveness[i] + deltaActiveness[i]);
      });
    });
  
    it('batchPopularitySetting', async function () {
      const newPopularitys = [4, 3, 2, 1];
      await this.Tavern.batchPopularitySetting(this.tokenIds, newPopularitys);
      const popularitys = await Promise.all(this.tokenIds.map(k =>
        this.Tavern.tavern.call(k).then(b => b[3].toNumber())
      ));
      popularitys.forEach((item, i) => {
        popularitys[i].should.be.equal(newPopularitys[i]);
      });
    });
  });
});
