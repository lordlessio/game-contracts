pragma solidity ^0.4.23;


contract IBuilding {

  function isBuildingContract() public pure returns (bool);
  function setInfluenceContract(address influenceContract) public;
  function getInfluenceContract() public view returns(address);
  function influenceByToken(uint256 _tokenId) public view returns(uint256);

  function building(uint256 _tokenId) external view returns (uint256, uint64, uint64, uint8, uint256);
  // function isBuilt(uint256 _tokenId) external view returns (bool);

  function build(
    uint256 _tokenId,
    uint64 _latitude,
    uint64 _longitude,
    uint8 _reputation
    ) external;

  // function mutiBuildingInit(uint256 _tokenId, uint256 lon, uint256 lat, uint8 reputation) external{}

  function activityUpgrade(uint256 _tokenId, uint256 _activity) external;
  function mutiActivityUpgrade(uint256 _tokenId, uint256 _activity) external;

  function reputationSetting(uint256 _tokenId, uint8 _reputation) external;
  function mutiReputationSetting(uint256 _tokenId, uint256 _activity) external;
}
