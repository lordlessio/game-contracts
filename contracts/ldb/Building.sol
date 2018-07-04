pragma solidity ^0.4.23;

import "./BuildingBase.sol";
import "./IBuilding.sol";
import "./IInfluence.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Building is IBuilding, BuildingBase, Superuser {
  
  IInfluence public influence;

  function isBuildingContract() public pure returns (bool){
    return true;
  }

  function setInfluenceContract(address influenceContract) onlySuperuser public{
    influence = IInfluence(influenceContract);
  }

  function getInfluenceContract() public view returns(address) {
    return address(influence);
  }
  
  function influenceByToken(uint256 _tokenId) public view returns(uint256) {
    return influence.influenceByToken(_tokenId);
  }

  function building(uint256 _tokenId) external view returns (uint256, uint64, uint64, uint8, uint256){
    return super._building(_tokenId);
  }

  function isBuilt(uint256 _tokenId) external view returns (bool){
    return super._isBuilt(_tokenId);
  }

  function build(
    uint256 _tokenId,
    uint64 _latitude,
    uint64 _longitude,
    uint8 _reputation
  ) external onlySuperuser {
    super._build(_tokenId, _latitude, _longitude, _reputation);
  }
  // function mutiBuildingInit(uint256 _tokenId, uint256 lon, uint256 lat, uint8 reputation) external{}

  function activityUpgrade(uint256 _tokenId, uint256 _activity) onlyOwnerOrSuperuser external {
    super._activityUpgrade(_tokenId, _activity);
  }
  function mutiActivityUpgrade(uint256 _tokenId, uint256 _activity) onlyOwnerOrSuperuser external {}

  function reputationSetting(uint256 _tokenId, uint8 _reputation) onlySuperuser external {
    super._reputationSetting(_tokenId, _reputation);
  }
  function mutiReputationSetting(uint256 _tokenId, uint256 _activity) onlySuperuser external {}
}
