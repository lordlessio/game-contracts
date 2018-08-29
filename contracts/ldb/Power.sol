pragma solidity ^0.4.24;

/**
* @title - Tavern's Power Algorithm
* Power contract implements the algorithm of Tavern equity attribute
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
import "./ITavern.sol";
import "../lib/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Power is Superuser, IPower{
  using SafeMath for *;
  ITavern public tavernContract;
  
  /**
   * @dev set the Tavern contract address
   * @return tavern Tavern contract address
   */
  function setTavernContract(address tavern) onlySuperuser external {
    tavernContract = ITavern(tavern);
  }

  /**
   * @dev get influence by token
   * @param tokenId tokenId
   * @return tavern Tavern contract address
   * influence is
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256){


    uint8 popularity;
    uint256 activeness;
    ( , , , popularity, activeness) = tavernContract.tavern(tokenId);
    return _influenceAlgorithm(popularity, activeness);
  }

  /**
   * @dev get Tavern's level by tokenId
   * @param tokenId tokenId
   * @return uint256 Tavern's level
   */
  function levelByToken(uint256 tokenId) external view returns(uint256){

    uint256 activeness;
    ( , , , , activeness) = tavernContract.tavern(tokenId);
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
  * @dev get Tavern's weightsApportion 
  * @param userLevel userLevel
  * @param lordLevel lordLevel
  * @return uint256 Tavern's weightsApportion
  * The candy that the user rewards when completing the candy mission will be assigned to the user and the lord. 
  * The distribution ratio is determined by weightsApportion
  */
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256) {
    return 2000 + 6000 * userLevel / (userLevel + lordLevel);
  }

}
