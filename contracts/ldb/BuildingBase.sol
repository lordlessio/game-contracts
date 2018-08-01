pragma solidity ^0.4.23;


import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "./IBuilding.sol";

contract BuildingBase is IBuilding {
  using SafeMath for uint256;

  struct LDB {
    uint256 initAt; // The time of ldb init
    int longitude; // The longitude of ldb
    int latitude; // The latitude of ldb
    uint8 reputation; // The reputation of ldb
    uint256 activity; // The activity of ldb
  }
  
  uint8 public constant decimals = 14; // longitude latitude decimals

  mapping(uint256 => LDB) internal tokenLDBs;
  
  function _building(uint256 _tokenId) internal view returns (uint256, int, int, uint8, uint256) {
    LDB storage ldb = tokenLDBs[_tokenId];
    return (
      ldb.initAt, 
      ldb.longitude, 
      ldb.latitude, 
      ldb.reputation, 
      ldb.activity
    );
  }
  // function getInfluence(uint256 _tokenId) external view returns (uint256){return ''}
  
  function _isBuilt(uint256 _tokenId) internal view returns (bool){
    LDB storage ldb = tokenLDBs[_tokenId];
    return (ldb.initAt > 0);
  }

  function _build(
    uint256 _tokenId,
    int _longitude,
    int _latitude,
    uint8 _reputation
    ) internal {

    // Check whether tokenid has been initialized
    require(!_isBuilt(_tokenId));
    require(_isLongitude(_longitude));
    require(_isLatitude(_latitude));
    
    uint256 time = block.timestamp;
    LDB memory ldb = LDB(
      time, _longitude, _latitude, _reputation, uint256(0)
    );
    tokenLDBs[_tokenId] = ldb;
    emit Build(time, _tokenId, _longitude, _latitude, _reputation);
  }
  
  function _multiBuild(
    uint256[] _tokenIds,
    int[] _longitudes,
    int[] _latitudes,
    uint8[] _reputations
    ) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _build(
        _tokenIds[i],
        _longitudes[i],
        _latitudes[i],
        _reputations[i]
      );
      i += 1;
    }

    
  }

  function _activityUpgrade(uint256 _tokenId, uint256 _deltaActivity) internal {
    require(_isBuilt(_tokenId));
    LDB storage ldb = tokenLDBs[_tokenId];
    uint256 oActivity = ldb.activity;
    uint256 newActivity = ldb.activity.add(_deltaActivity);
    ldb.activity = newActivity;
    tokenLDBs[_tokenId] = ldb;
    emit ActivityUpgrade(_tokenId, oActivity, newActivity);
  }
  function _multiActivityUpgrade(uint256[] _tokenIds, uint256[] __deltaActivities) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _activityUpgrade(_tokenIds[i], __deltaActivities[i]);
      i += 1;
    }
  }

  function _reputationSetting(uint256 _tokenId, uint8 _reputation) internal {
    require(_isBuilt(_tokenId));
    uint8 oReputation = tokenLDBs[_tokenId].reputation;
    tokenLDBs[_tokenId].reputation = _reputation;
    emit ReputationSetting(_tokenId, oReputation, _reputation);
  }

  function _multiReputationSetting(uint256[] _tokenIds, uint8[] _reputations) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _reputationSetting(_tokenIds[i], _reputations[i]);
      i += 1;
    }
  }

  function _isLongitude (
    int _param
  ) internal pure returns (bool){
    return( _param <= 180 * int(10 ** uint256(decimals)));
  } 

  function _isLatitude (
    int _param
  ) internal pure returns (bool){
    return( _param <= 90 * int(10 ** uint256(decimals)));
  } 
}
