pragma solidity ^0.4.23;

interface IInfluence {
  function setBuildingContract(address building) external;
  function getBuildingContract() external view returns(address);
  function influenceByToken(uint256 tokenId) external view returns(uint256);
}