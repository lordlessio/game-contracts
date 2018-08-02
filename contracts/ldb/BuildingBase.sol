pragma solidity ^0.4.23;


import "../lib/SafeMath.sol";
import "./IBuilding.sol";

contract BuildingBase is IBuilding {
  using SafeMath for *;

  struct LDB {
    uint256 initAt; // The time of ldb init
    int longitude; // The longitude of ldb
    int latitude; // The latitude of ldb
    uint8 popularity; // The popularity of ldb
    uint256 activeness; // The activeness of ldb
  }
  
  uint8 public constant decimals = 14; // longitude latitude decimals

  mapping(uint256 => LDB) internal tokenLDBs;
  
  function _building(uint256 _tokenId) internal view returns (uint256, int, int, uint8, uint256) {
    LDB storage ldb = tokenLDBs[_tokenId];
    return (
      ldb.initAt, 
      ldb.longitude, 
      ldb.latitude, 
      ldb.popularity, 
      ldb.activeness
    );
  }
  
  function _isBuilt(uint256 _tokenId) internal view returns (bool){
    LDB storage ldb = tokenLDBs[_tokenId];
    return (ldb.initAt > 0);
  }

  function _build(
    uint256 _tokenId,
    int _longitude,
    int _latitude,
    uint8 _popularity
    ) internal {

    // Check whether tokenid has been initialized
    require(!_isBuilt(_tokenId));
    require(_isLongitude(_longitude));
    require(_isLatitude(_latitude));
    
    uint256 time = block.timestamp;
    LDB memory ldb = LDB(
      time, _longitude, _latitude, _popularity, uint256(0)
    );
    tokenLDBs[_tokenId] = ldb;
    emit Build(time, _tokenId, _longitude, _latitude, _popularity);
  }
  
  function _batchBuild(
    uint256[] _tokenIds,
    int[] _longitudes,
    int[] _latitudes,
    uint8[] _popularitys
    ) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _build(
        _tokenIds[i],
        _longitudes[i],
        _latitudes[i],
        _popularitys[i]
      );
      i += 1;
    }

    
  }

  function _activenessUpgrade(uint256 _tokenId, uint256 _deltaActiveness) internal {
    require(_isBuilt(_tokenId));
    LDB storage ldb = tokenLDBs[_tokenId];
    uint256 oActiveness = ldb.activeness;
    uint256 newActiveness = ldb.activeness.add(_deltaActiveness);
    ldb.activeness = newActiveness;
    tokenLDBs[_tokenId] = ldb;
    emit ActivenessUpgrade(_tokenId, oActiveness, newActiveness);
  }
  function _batchActivenessUpgrade(uint256[] _tokenIds, uint256[] __deltaActiveness) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _activenessUpgrade(_tokenIds[i], __deltaActiveness[i]);
      i += 1;
    }
  }

  function _popularitySetting(uint256 _tokenId, uint8 _popularity) internal {
    require(_isBuilt(_tokenId));
    uint8 oPopularity = tokenLDBs[_tokenId].popularity;
    tokenLDBs[_tokenId].popularity = _popularity;
    emit PopularitySetting(_tokenId, oPopularity, _popularity);
  }

  function _batchPopularitySetting(uint256[] _tokenIds, uint8[] _popularitys) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _popularitySetting(_tokenIds[i], _popularitys[i]);
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
