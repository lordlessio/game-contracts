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
    uint8 popularity
    ) external;

  function batchBuild(
    uint256[] tokenIds,
    int[] longitudes,
    int[] latitudes,
    uint8[] popularitys
    ) external;

  function activenessUpgrade(uint256 tokenId, uint256 deltaActiveness) external;
  function batchActivenessUpgrade(uint256[] tokenIds, uint256[] deltaActiveness) external;

  function popularitySetting(uint256 tokenId, uint8 popularity) external;
  function batchPopularitySetting(uint256[] tokenIds, uint8[] popularitys) external;
  
  /* Events */

  event Build (
    uint256 time,
    uint256 indexed tokenId,
    int longitude,
    int latitude,
    uint8 popularity
  );

  event ActivenessUpgrade (
    uint256 indexed tokenId,
    uint256 oActiveness,
    uint256 newActiveness
  );

  event PopularitySetting (
    uint256 indexed tokenId,
    uint256 oPopularity,
    uint256 newPopularity
  );
}
