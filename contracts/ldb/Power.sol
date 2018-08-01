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


    uint8 popularity;
    uint256 activeness;
    ( , , , popularity, activeness) = buildingContract.building(tokenId);
    return _influenceAlgorithm(popularity, activeness);
  }

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

  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256) {
    return 2000 + 6000 * userLevel / (userLevel + lordLevel);
  }

}
