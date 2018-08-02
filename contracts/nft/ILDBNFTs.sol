pragma solidity ^0.4.23;
import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract ILDBNFTs is ERC721 {
  function mint(address to, uint256 tokenId) public;
  function burn(uint256 tokenId) public;
  function setTokenURI(uint256 tokenId, string uri) public;
  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256);
}