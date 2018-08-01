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
import "./IPower.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Building is IBuilding, BuildingBase, Superuser {
  
  IPower public powerContract;

  /**
   * @dev check if contract is BuildingContract
   * @return bool isBuildingContract
   */
  function isBuildingContract() external pure returns (bool){
    return true;
  }

  /**
   * @dev set power contract address
   * @param _powerContract contract address
   */
  function setPowerContract(address _powerContract) onlySuperuser external{
    powerContract = IPower(_powerContract);
  }

  
  /**
   * @dev get LDB's influence by tokenId
   * @param tokenId tokenId
   * @return uint256 LDB's influence 
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256) {
    return powerContract.influenceByToken(tokenId);
  }


  /**
   * @dev get LDB's weightsApportion 
   * @param userLevel userLevel
   * @param lordLevel lordLevel
   * @return uint256 LDB's level
   */
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256){
    return powerContract.weightsApportion(userLevel, lordLevel);
  }

  /**
   * @dev get LDB's level by tokenId
   * @param tokenId tokenId
   * @return uint256 LDB's level
   */
  function levelByToken(uint256 tokenId) external view returns(uint256) {
    return powerContract.levelByToken(tokenId);
  }

  /**
   * @dev get a Building's infomation 
   * @param tokenId tokenId
   * @return uint256 LDB's construction time
   * @return int LDB's longitude value 
   * @return int LDB's latitude value
   * @return uint8 LDB's popularity
   * @return uint256 LDB's activeness
   */
  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256){
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
   * @param latitude latitude value
   * @param popularity popularity
   */
  function build(
    uint256 tokenId,
    int longitude,
    int latitude,
    uint8 popularity
  ) external onlySuperuser {
    super._build(tokenId, longitude, latitude, popularity);
  }

  /**
   * @dev build multi building in one transaction
   * @param tokenIds Array of tokenId
   * @param longitudes Array of longitude value 
   * @param latitudes Array of latitude value
   * @param popularitys Array of popularity
   */
  function multiBuild(
    uint256[] tokenIds,
    int[] longitudes,
    int[] latitudes,
    uint8[] popularitys
    ) external onlySuperuser{

    super._multiBuild(
      tokenIds,
      longitudes,
      latitudes,
      popularitys
    );
  }

  /**
   * @dev upgrade LDB's activeness 
   * @param tokenId tokenId
   * @param deltaActiveness delta activeness
   */
  function activenessUpgrade(uint256 tokenId, uint256 deltaActiveness) onlyOwnerOrSuperuser external {
    super._activenessUpgrade(tokenId, deltaActiveness);
  }

  /**
   * @dev upgrade multi LDBs's activeness 
   * @param tokenIds Array of tokenId
   * @param deltaActiveness  array of delta activeness
   */
  function multiActivenessUpgrade(uint256[] tokenIds, uint256[] deltaActiveness) onlyOwnerOrSuperuser external {
    super._multiActivenessUpgrade(tokenIds, deltaActiveness);
  }

  /**
   * @dev set LDBs's popularity 
   * @param tokenId LDB's tokenId
   * @param popularity LDB's popularity
   */
  function popularitySetting(uint256 tokenId, uint8 popularity) onlySuperuser external {
    super._popularitySetting(tokenId, popularity);
  }

  /**
   * @dev set multi LDBs's popularity 
   * @param tokenIds Array of tokenId
   * @param popularitys Array of popularity
   */
  function multiPopularitySetting(uint256[] tokenIds, uint8[] popularitys) onlySuperuser external {
    super._multiPopularitySetting(tokenIds, popularitys);
  }
}
