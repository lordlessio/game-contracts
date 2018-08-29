pragma solidity ^0.4.24;

/**
 * @title -LORDLESS tavern - Tavern
 * Tavern contract records the core attributes of Tavern
 * 
 * ████████╗  █████╗  ██╗   ██╗ ███████╗ ██████╗  ███╗   ██╗ ██╗
 * ╚══██╔══╝ ██╔══██╗ ██║   ██║ ██╔════╝ ██╔══██╗ ████╗  ██║ ██║
 *    ██║    ███████║ ██║   ██║ █████╗   ██████╔╝ ██╔██╗ ██║ ██║
 *    ██║    ██╔══██║ ╚██╗ ██╔╝ ██╔══╝   ██╔══██╗ ██║╚██╗██║ ╚═╝
 *    ██║    ██║  ██║  ╚████╔╝  ███████╗ ██║  ██║ ██║ ╚████║ ██╗
 *    ╚═╝    ╚═╝  ╚═╝   ╚═══╝   ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝
 * 
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * game at https://lordless.io
 * code at https://github.com/lordlessio
 */

import "./TavernBase.sol";
import "./ITavern.sol";
import "./IPower.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Tavern is ITavern, TavernBase, Superuser {
  
  IPower public powerContract;

  /**
   * @dev set power contract address
   * @param _powerContract contract address
   */
  function setPowerContract(address _powerContract) onlySuperuser external{
    powerContract = IPower(_powerContract);
  }

  
  /**
   * @dev get Tavern's influence by tokenId
   * @param tokenId tokenId
   * @return uint256 Tavern's influence 
   *
   * The influence of Tavern determines its ability to distribute candy daily.
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256) {
    return powerContract.influenceByToken(tokenId);
  }


  /**
   * @dev get Tavern's weightsApportion 
   * @param userLevel userLevel
   * @param lordLevel lordLevel
   * @return uint256 Tavern's weightsApportion
   * The candy that the user rewards when completing the candy mission will be assigned to the user and the lord. 
   * The distribution ratio is determined by weightsApportion
   */
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256){
    return powerContract.weightsApportion(userLevel, lordLevel);
  }

  /**
   * @dev get Tavern's level by tokenId
   * @param tokenId tokenId
   * @return uint256 Tavern's level
   */
  function levelByToken(uint256 tokenId) external view returns(uint256) {
    return powerContract.levelByToken(tokenId);
  }

  /**
   * @dev get a Tavern's infomation 
   * @param tokenId tokenId
   * @return uint256 Tavern's construction time
   * @return int Tavern's longitude value 
   * @return int Tavern's latitude value
   * @return uint8 Tavern's popularity
   * @return uint256 Tavern's activeness
   */
  function tavern(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256){
    return super._tavern(tokenId);
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
   * @dev build a tavern
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
   * @dev build batch tavern in one transaction
   * @param tokenIds Array of tokenId
   * @param longitudes Array of longitude value 
   * @param latitudes Array of latitude value
   * @param popularitys Array of popularity
   */
  function batchBuild(
    uint256[] tokenIds,
    int[] longitudes,
    int[] latitudes,
    uint8[] popularitys
    ) external onlySuperuser{

    super._batchBuild(
      tokenIds,
      longitudes,
      latitudes,
      popularitys
    );
  }

  /**
   * @dev upgrade Tavern's activeness 
   * @param tokenId tokenId
   * @param deltaActiveness delta activeness
   */
  function activenessUpgrade(uint256 tokenId, uint256 deltaActiveness) onlyOwnerOrSuperuser external {
    super._activenessUpgrade(tokenId, deltaActiveness);
  }

  /**
   * @dev upgrade batch Taverns's activeness 
   * @param tokenIds Array of tokenId
   * @param deltaActiveness  array of delta activeness
   */
  function batchActivenessUpgrade(uint256[] tokenIds, uint256[] deltaActiveness) onlyOwnerOrSuperuser external {
    super._batchActivenessUpgrade(tokenIds, deltaActiveness);
  }

  /**
   * @dev set Taverns's popularity 
   * @param tokenId Tavern's tokenId
   * @param popularity Tavern's popularity
   */
  function popularitySetting(uint256 tokenId, uint8 popularity) onlySuperuser external {
    super._popularitySetting(tokenId, popularity);
  }

  /**
   * @dev set batch Taverns's popularity 
   * @param tokenIds Array of tokenId
   * @param popularitys Array of popularity
   */
  function batchPopularitySetting(uint256[] tokenIds, uint8[] popularitys) onlySuperuser external {
    super._batchPopularitySetting(tokenIds, popularitys);
  }
}
