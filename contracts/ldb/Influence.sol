pragma solidity ^0.4.23;

import "./IInfluence.sol";
import "./IBuilding.sol";
import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";

contract Influence is Superuser, IInfluence{
  using SafeMath for uint256;
  IBuilding public buildingContract;

  function setBuildingContract(address building) onlySuperuser public {

    require(IBuilding(building).isBuildingContract());
    buildingContract = IBuilding(building);
  }

  function getBuildingContract() public view returns(address){
    return address(buildingContract);
  }

  function influenceByToken(uint256 _tokenId) public view returns(uint256){

    // uint256 initAt;
    uint8 reputation;
    uint256 activity;
    (, , , , reputation, activity) = buildingContract.building(_tokenId);
    return _influenceAlgorithm(reputation, activity);
  }

  function _influenceAlgorithm(uint8 _reputation, uint256 _activity) internal pure returns (uint256) {
    uint256 reputation = uint256(_reputation);
    return reputation.mul(_activity).add(reputation);
  }
}
