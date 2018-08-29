pragma solidity ^0.4.24;


import "../lib/SafeMath.sol";
import "./ITavern.sol";

contract TavernBase is ITavern {
  using SafeMath for *;

  struct Tavern {
    uint256 initAt; // The time of tavern init
    int longitude; // The longitude of tavern
    int latitude; // The latitude of tavern
    uint8 popularity; // The popularity of tavern
    uint256 activeness; // The activeness of tavern
  }
  
  uint8 public constant decimals = 16; // longitude latitude decimals

  mapping(uint256 => Tavern) internal tokenTaverns;
  
  function _tavern(uint256 _tokenId) internal view returns (uint256, int, int, uint8, uint256) {
    Tavern storage tavern = tokenTaverns[_tokenId];
    return (
      tavern.initAt, 
      tavern.longitude, 
      tavern.latitude, 
      tavern.popularity, 
      tavern.activeness
    );
  }
  
  function _isBuilt(uint256 _tokenId) internal view returns (bool){
    Tavern storage tavern = tokenTaverns[_tokenId];
    return (tavern.initAt > 0);
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
    require(_popularity != 0);
    uint256 time = block.timestamp;
    Tavern memory tavern = Tavern(
      time, _longitude, _latitude, _popularity, uint256(0)
    );
    tokenTaverns[_tokenId] = tavern;
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
    Tavern storage tavern = tokenTaverns[_tokenId];
    uint256 oActiveness = tavern.activeness;
    uint256 newActiveness = tavern.activeness.add(_deltaActiveness);
    tavern.activeness = newActiveness;
    tokenTaverns[_tokenId] = tavern;
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
    uint8 oPopularity = tokenTaverns[_tokenId].popularity;
    tokenTaverns[_tokenId].popularity = _popularity;
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
    
    return( 
      _param <= 180 * int(10 ** uint256(decimals))&&
      _param >= -180 * int(10 ** uint256(decimals))
      );
  } 

  function _isLatitude (
    int _param
  ) internal pure returns (bool){
    return( 
      _param <= 90 * int(10 ** uint256(decimals))&&
      _param >= -90 * int(10 ** uint256(decimals))
      );
  } 
}
