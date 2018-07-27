pragma solidity ^0.4.23;

/**
 * @title -LORDLESS BUILDING - LDB
 *
 * ██████╗  ██╗   ██╗ ██╗ ██╗      ██████╗  ██╗ ███╗   ██╗  ██████╗  ██╗
 * ██╔══██╗ ██║   ██║ ██║ ██║      ██╔══██╗ ██║ ████╗  ██║ ██╔════╝  ██║
 * ██████╔╝ ██║   ██║ ██║ ██║      ██║  ██║ ██║ ██╔██╗ ██║ ██║  ███╗ ██║
 * ██╔══██╗ ██║   ██║ ██║ ██║      ██║  ██║ ██║ ██║╚██╗██║ ██║   ██║ ╚═╝
 * ██████╔╝ ╚██████╔╝ ██║ ███████╗ ██████╔╝ ██║ ██║ ╚████║ ╚██████╔╝ ██╗
 * ╚═════╝   ╚═════╝  ╚═╝ ╚══════╝ ╚═════╝  ╚═╝ ╚═╝  ╚═══╝  ╚═════╝  ╚═╝
 * 
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * 
 */

import "./BuildingBase.sol";
import "./IBuilding.sol";
import "./IInfluence.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Building is IBuilding, BuildingBase, Superuser {
  
  IInfluence public influence;

  /**
   * @dev check if contract is BuildingContract
   * @return bool isBuildingContract
   */
  function isBuildingContract() external pure returns (bool){
    return true;
  }

  /**
   * @dev set influence algorithm contract address
   * @param influenceContract contract address
   */
  function setInfluenceContract(address influenceContract) onlySuperuser external{
    influence = IInfluence(influenceContract);
  }

  /**
   * @dev set influence algorithm contract address
   * @return address contract address
   */
  function getInfluenceContract() external view returns(address) {
    return address(influence);
  }
  
  /**
   * @dev get LDB's influence by tokenId
   * @param tokenId tokenId
   * @return uint256 LDB's influence 
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256) {
    return influence.influenceByToken(tokenId);
  }

  /**
   * @dev get a Building's infomation 
   * @param tokenId tokenId
   * @return uint256 LDB's construction time
   * @return uint256 LDB's longitude value 
   * @return bool if LDB's longitudeNegative
   * @return uint256 LDB's latitude value
   * @return bool LDB's latitudeNegative 
   * @return uint8 LDB's reputation
   * @return uint256 LDB's activity
   */
  function building(uint256 tokenId) external view returns (uint256, uint64, bool, uint64, bool, uint8, uint256){
    return super._building(tokenId);
  }

  /**
   * @dev check the tokenId is built 
   * @param tokenId tokenId
   * @return bool tokenId is built 
   */
  function isBuilt(uint256 tokenId) external view returns (bool){
    return super._isBuilt(tokenId);
  }

  /**
   * @dev build a building
   * @param tokenId tokenId
   * @param longitude longitude value 
   * @param longitudeNegative longitudeNegative
   * @param latitude latitude value
   * @param latitudeNegative latitudeNegative 
   * @param reputation reputation
   */
  function build(
    uint256 tokenId,
    uint64 longitude,
    bool longitudeNegative,
    uint64 latitude,
    bool latitudeNegative,
    uint8 reputation
  ) external onlySuperuser {
    super._build(tokenId, longitude, longitudeNegative, latitude, latitudeNegative, reputation);
  }

  /**
   * @dev build multi building in one transaction
   * @param tokenIds Array of tokenId
   * @param longitudes Array of longitude value 
   * @param longitudesNegative Array of longitudeNegative
   * @param latitudes Array of latitude value
   * @param latitudesNegative Array of latitudeNegative 
   * @param reputations Array of reputation
   */
  function multiBuild(
    uint256[] tokenIds,
    uint64[] longitudes,
    bool[] longitudesNegative,
    uint64[] latitudes,
    bool[] latitudesNegative,
    uint8[] reputations
    ) external onlySuperuser{

    super._multiBuild(
      tokenIds,
      longitudes,
      longitudesNegative,
      latitudes,
      latitudesNegative,
      reputations
    );
  }

  /**
   * @dev upgrade LDB's activity 
   * @param tokenId tokenId
   * @param deltaActivity delta activity
   */
  function activityUpgrade(uint256 tokenId, uint256 deltaActivity) onlyOwnerOrSuperuser external {
    super._activityUpgrade(tokenId, deltaActivity);
  }

  /**
   * @dev upgrade multi LDBs's activity 
   * @param tokenIds Array of tokenId
   * @param deltaActivities  array of delta activity
   */
  function multiActivityUpgrade(uint256[] tokenIds, uint256[] deltaActivities) onlyOwnerOrSuperuser external {
    super._multiActivityUpgrade(tokenIds, deltaActivities);
  }

  /**
   * @dev set LDBs's reputation 
   * @param tokenId LDB's tokenId
   * @param reputation LDB's reputation
   */
  function reputationSetting(uint256 tokenId, uint8 reputation) onlySuperuser external {
    super._reputationSetting(tokenId, reputation);
  }

  /**
   * @dev set multi LDBs's reputation 
   * @param tokenIds Array of tokenId
   * @param reputations Array of reputation
   */
  function multiReputationSetting(uint256[] tokenIds, uint8[] reputations) onlySuperuser external {
    super._multiReputationSetting(tokenIds, reputations);
  }
}
