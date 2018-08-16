pragma solidity ^0.4.24;

interface IPower {
  function setBuildingContract(address building) external;
  function influenceByToken(uint256 tokenId) external view returns(uint256);
  function levelByToken(uint256 tokenId) external view returns(uint256);
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256);
}