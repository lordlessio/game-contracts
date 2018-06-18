pragma solidity ^0.4.23;

// import "../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

import "./LdbERC721Token.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title LdbERC721Token
 * This contract just provides a public mint / burn / setLdbNFTToken functions 
 */
contract LdbNFT is LdbERC721Token, Ownable {
  function LdbNFT(string name, string symbol) public
    LdbERC721Token(name, symbol)
  {}

  function mint(address _to, uint256 _tokenId) public onlyOwner {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) public onlyOwner {
    super._burn(ownerOf(_tokenId), _tokenId);
  }

  function setLdbNFT(uint256 _tokenId, uint32 _lat, uint32 _lon) public onlyOwner {
    super._setLdbNFT(_tokenId, _lat, _lon);
  }
}
