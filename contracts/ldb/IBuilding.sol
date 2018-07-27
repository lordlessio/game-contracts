pragma solidity ^0.4.23;

/**
 * @title LDB Interface
 */

interface IBuilding {

  function isBuildingContract() external pure returns (bool);
  function setInfluenceContract(address influenceContract) external;
  function getInfluenceContract() external view returns(address);
  function influenceByToken(uint256 tokenId) external view returns(uint256);

  function building(uint256 tokenId) external view returns (uint256, uint64, bool, uint64, bool, uint8, uint256);
  function isBuilt(uint256 tokenId) external view returns (bool);

  function build(
    uint256 tokenId,
    uint64 longitude,
    bool longitudeNegative,
    uint64 latitude,
    bool latitudeNegative,
    uint8 reputation
    ) external;

  function multiBuild(
    uint256[] tokenIds,
    uint64[] longitudes,
    bool[] longitudesNegative,
    uint64[] latitudes,
    bool[] latitudesNegative,
    uint8[] reputations
    ) external;

  function activityUpgrade(uint256 tokenId, uint256 deltaActivity) external;
  function multiActivityUpgrade(uint256[] tokenIds, uint256[] deltaActivities) external;

  function reputationSetting(uint256 tokenId, uint8 reputation) external;
  function multiReputationSetting(uint256[] tokenIds, uint8[] reputations) external;
  
  /* Events */

  event Build (
    uint256 time,
    uint256 indexed tokenId,
    uint64 longitude,
    bool longitudeNegative,
    uint64 latitude,
    bool latitudeNegative,
    uint8 reputation
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
}
