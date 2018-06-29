pragma solidity ^0.4.23;

/**
 *  Influence Interface
 */
contract IInfluence {
  function setBuildingContract(address building) public;
  // function getBuildingContract() public view returns(address);
  function influenceByToken(uint256 _tokenId) public view returns(uint256);
}