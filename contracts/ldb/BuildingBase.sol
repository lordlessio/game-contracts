pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract BuildingBase {
  using SafeMath for uint256;

  struct LDB {

    // The time of ldb init
    uint256 initAt;

    // The latitude of ldb
    uint64 latitude;

    // The longitude of ldb
    uint64 longitude;

    // The reputation of ldb
    uint8 reputation;

    // The activity of ldb
    uint256 activity;

  }

  uint8 public constant decimals = 14;

  mapping(uint256 => LDB) internal tokenLDBs;

  /* Events */

  event Build (
    uint256 indexed tokenId,
    uint64 _latitude,
    uint64 _longitude,
    uint8 _reputation
  );

  event ActivityUpgrade (
    uint256 indexed tokenId,
    uint256 oActivity,
    uint256 newActivity
  );

  event ReputationSetting (
    uint256 indexed tokenId,
    uint256 oReputation,
    uint256 newReputation
  );
  function _building(uint256 _tokenId) internal view returns (uint256, uint64, uint64, uint8, uint256) {
    LDB storage ldb = tokenLDBs[_tokenId];
    return (ldb.initAt, ldb.latitude, ldb.longitude, ldb.reputation, ldb.activity);
  }
  // function getInfluence(uint256 _tokenId) external view returns (uint256){return ''}
  
  /**
   * @dev check the building is built
   */
  function _isBuilt(uint256 _tokenId) internal view returns (bool){
    LDB storage ldb = tokenLDBs[_tokenId];
    return (ldb.initAt > 0);
  }

  function _build(
    uint256 _tokenId,
    uint64 _latitude,
    uint64 _longitude,
    uint8 _reputation
    ) internal {

    // Check whether tokenid has been initialized
    require(!_isBuilt(_tokenId));
    require(tokenLDBs[_tokenId].initAt == uint256(0));

    require(_isValidGEO(_latitude));
    require(_isValidGEO(_longitude));
    uint256 time = block.timestamp;
    LDB memory ldb = LDB(
      time, _latitude, _longitude, _reputation, uint256(0)
    );
    tokenLDBs[_tokenId] = ldb;
    emit Build(time, _latitude, _longitude, _reputation);
  }
  
  function _mutiBuild(uint256 _tokenId, uint256 _activity) internal {
    // todo
  }

  function _activityUpgrade(uint256 _tokenId, uint256 _activity) internal {
    LDB storage ldb = tokenLDBs[_tokenId];
    uint256 oActivity = ldb.activity;
    uint256 newActivity = ldb.activity.add(_activity);
    ldb.activity = newActivity;
    tokenLDBs[_tokenId] = ldb;
    emit ActivityUpgrade(_tokenId, oActivity, newActivity);
  }
  function _mutiActivityUpgrade(uint256 _tokenId, uint256 _activity) internal {
     // todo
  }

  function _reputationSetting(uint256 _tokenId, uint8 _reputation) internal {
    require(_isBuilt(_tokenId));
    uint8 oReputation = tokenLDBs[_tokenId].reputation;
    tokenLDBs[_tokenId].reputation = _reputation;
    emit ReputationSetting(_tokenId, oReputation, _reputation);
  }

  function _mutiReputationSetting(uint256 _tokenId, uint256 _Reputation) internal {
     // todo
  }

  function _isValidGEO (
    uint64 _param
  ) internal pure returns (bool){
    return( uint256(_param) < 10 ** uint256(decimals + 1));
  } 

}
