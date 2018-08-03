pragma solidity ^0.4.23;

/**
* @title - LDB's Power Algorithm
* Power contract implements the algorithm of LDB equity attribute
*
* ██████╗   ██████╗  ██╗    ██╗ ███████╗ ██████╗  ██╗
* ██╔══██╗ ██╔═══██╗ ██║    ██║ ██╔════╝ ██╔══██╗ ██║
* ██████╔╝ ██║   ██║ ██║ █╗ ██║ █████╗   ██████╔╝ ██║
* ██╔═══╝  ██║   ██║ ██║███╗██║ ██╔══╝   ██╔══██╗ ╚═╝
* ██║      ╚██████╔╝ ╚███╔███╔╝ ███████╗ ██║  ██║ ██╗
* ╚═╝       ╚═════╝   ╚══╝╚══╝  ╚══════╝ ╚═╝  ╚═╝ ╚═╝
*
* ---
* POWERED BY
* ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
* ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
* ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
* game at https://lordless.io
* code at https://github.com/lordlessio
*/

import "./IPower.sol";
import "./IBuilding.sol";
import "../lib/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Power is Superuser, IPower{
  using SafeMath for *;
  IBuilding public buildingContract;
  
  /**
   * @dev set the LDB contract address
   * @return building LDB contract address
   */
  function setBuildingContract(address building) onlySuperuser external {
    buildingContract = IBuilding(building);
  }

  /**
   * @dev get influence by token
   * @param tokenId tokenId
   * @return building LDB contract address
   * influence is
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256){


    uint8 popularity;
    uint256 activeness;
    ( , , , popularity, activeness) = buildingContract.building(tokenId);
    return _influenceAlgorithm(popularity, activeness);
  }

  /**
   * @dev get LDB's level by tokenId
   * @param tokenId tokenId
   * @return uint256 LDB's level
   */
  function levelByToken(uint256 tokenId) external view returns(uint256){

    uint256 activeness;
    ( , , , , activeness) = buildingContract.building(tokenId);
    return _activeness2level(activeness);
  }

  function _influenceAlgorithm(uint8 _popularity, uint256 _activeness) internal pure returns (uint256) {
    uint256 popularity = uint256(_popularity);
    return popularity.mul(_activeness).add(popularity);
  }
  
  function _activeness2level(uint256 _activeness) internal pure returns (uint256) {
    return (_activeness.mul(uint(108).sq())/10).sqrt()/108 + 1;
  }

  uint public constant weightsApportionDecimals = 4;
  /**
  * @dev get LDB's weightsApportion 
  * @param userLevel userLevel
  * @param lordLevel lordLevel
  * @return uint256 LDB's weightsApportion
  * The candy that the user rewards when completing the candy mission will be assigned to the user and the lord. 
  * The distribution ratio is determined by weightsApportion
  */
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256) {
    return 2000 + 6000 * userLevel / (userLevel + lordLevel);
  }

}
