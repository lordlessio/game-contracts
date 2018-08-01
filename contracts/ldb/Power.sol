pragma solidity ^0.4.23;

/**
* @title - LDB's Power Algorithm
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

    require(IBuilding(building).isBuildingContract());
    buildingContract = IBuilding(building);
  }

  /**
   * @dev get influence by token
   * @param tokenId tokenId
   * @return building LDB contract address
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256){


    uint8 reputation;
    uint256 activity;
    ( , , , reputation, activity) = buildingContract.building(tokenId);
    return _influenceAlgorithm(reputation, activity);
  }

  function levelByToken(uint256 tokenId) external view returns(uint256){

    uint256 activity;
    ( , , , , activity) = buildingContract.building(tokenId);
    return _activity2level(activity);
  }

  function _influenceAlgorithm(uint8 _reputation, uint256 _activity) internal pure returns (uint256) {
    uint256 reputation = uint256(_reputation);
    return reputation.mul(_activity).add(reputation);
  }

  function _activity2level(uint256 _activity) internal pure returns (uint256) {
    return (_activity.mul(uint(108).sq())/10).sqrt()/108 + 1;
  }

  uint public constant weightsApportionDecimals = 4;

  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256) {
    return 2000 + 6000 * userLevel / (userLevel + lordLevel);
  }

}
