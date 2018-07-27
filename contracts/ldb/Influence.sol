pragma solidity ^0.4.23;

/**
* @title - LDB Influence Algorithm
*
* ██╗ ███╗   ██╗ ███████╗ ██╗      ██╗   ██╗ ███████╗ ███╗   ██╗  ██████╗ ███████╗ ██╗
* ██║ ████╗  ██║ ██╔════╝ ██║      ██║   ██║ ██╔════╝ ████╗  ██║ ██╔════╝ ██╔════╝ ██║
* ██║ ██╔██╗ ██║ █████╗   ██║      ██║   ██║ █████╗   ██╔██╗ ██║ ██║      █████╗   ██║
* ██║ ██║╚██╗██║ ██╔══╝   ██║      ██║   ██║ ██╔══╝   ██║╚██╗██║ ██║      ██╔══╝   ╚═╝
* ██║ ██║ ╚████║ ██║      ███████╗ ╚██████╔╝ ███████╗ ██║ ╚████║ ╚██████╗ ███████╗ ██╗
* ╚═╝ ╚═╝  ╚═══╝ ╚═╝      ╚══════╝  ╚═════╝  ╚══════╝ ╚═╝  ╚═══╝  ╚═════╝ ╚══════╝ ╚═╝
*
* ---
* POWERED BY
* ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
* ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
* ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
*/

import "./IInfluence.sol";
import "./IBuilding.sol";
import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Influence is Superuser, IInfluence{
  using SafeMath for uint256;
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
   * @dev get the LDB contract address
   * @return building LDB contract address
   */
  function getBuildingContract() external view returns(address){
    return address(buildingContract);
  }

  /**
   * @dev get influence by token
   * @param tokenId tokenId
   * @return building LDB contract address
   */
  function influenceByToken(uint256 tokenId) external view returns(uint256){

    // uint256 initAt;
    uint8 reputation;
    uint256 activity;
    ( , , , , ,reputation, activity) = buildingContract.building(tokenId);
    return _influenceAlgorithm(reputation, activity);
  }

  function _influenceAlgorithm(uint8 _reputation, uint256 _activity) internal pure returns (uint256) {
    uint256 reputation = uint256(_reputation);
    return reputation.mul(_activity).add(reputation);
  }
}
