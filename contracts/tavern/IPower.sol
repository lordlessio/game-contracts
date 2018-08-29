pragma solidity ^0.4.24;

interface IPower {
  function setTavernContract(address tavern) external;
  function influenceByToken(uint256 tokenId) external view returns(uint256);
  function levelByToken(uint256 tokenId) external view returns(uint256);
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256);

   /* Events */

  event SetTavernContract (
    address tavern
  );
}