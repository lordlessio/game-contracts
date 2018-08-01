pragma solidity ^0.4.23;

/**
 * @title LDB Interface
 */

interface IBuilding {

  function isBuildingContract() external pure returns (bool);
  function setPowerContract(address _powerContract) external;
  function influenceByToken(uint256 tokenId) external view returns(uint256);
  function levelByToken(uint256 tokenId) external view returns(uint256);
  function weightsApportion(uint256 ulevel1, uint256 ulevel2) external view returns(uint256);
  
  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256);
  function isBuilt(uint256 tokenId) external view returns (bool);

  function build(
    uint256 tokenId,
    int longitude,
    int latitude,
    uint8 reputation
    ) external;

  function multiBuild(
    uint256[] tokenIds,
    int[] longitudes,
    int[] latitudes,
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
    int longitude,
    int latitude,
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
