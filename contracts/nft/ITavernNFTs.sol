pragma solidity ^0.4.24;
import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract ITavernNFTs is ERC721 {
  function setTavernContract(address tavern) external;
  function mint(address to, uint256 tokenId) public;
  function batchMint(address[] tos, uint256[] tokenIds) external;
  function burn(uint256 tokenId) public;
  function setTokenURI(uint256 tokenId, string uri) public;
  function tavern(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256);

  /* Events */

  event SetTavernContract (
    address tavern
  );

}