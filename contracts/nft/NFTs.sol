pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
/**
 * @title LDBNFTs - LORDLESS BUILDING NFTs Contract
 * @dev This contract only records the relationship of TOKEN ID ownership.
 * 
 * ██╗      ██████╗  ██████╗  ███╗   ██╗ ███████╗ ████████╗ ███████╗ ██╗
 * ██║      ██╔══██╗ ██╔══██╗ ████╗  ██║ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██║
 * ██║      ██║  ██║ ██████╔╝ ██╔██╗ ██║ █████╗      ██║    ███████╗ ██║
 * ██║      ██║  ██║ ██╔══██╗ ██║╚██╗██║ ██╔══╝      ██║    ╚════██║ ╚═╝
 * ███████╗ ██████╔╝ ██████╔╝ ██║ ╚████║ ██║         ██║    ███████║ ██╗
 * ╚══════╝ ╚═════╝  ╚═════╝  ╚═╝  ╚═══╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝
 *
 * Visit the https://github.com/lordlessio/ldb-nft for more details
 * 
 */
contract LDBNFTs is ERC721Token, Superuser {
  constructor(string name, string symbol) public
    ERC721Token(name, symbol)
  { }

  function mint(address _to, uint256 _tokenId) onlySuperuser public {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) onlySuperuser public {
    super._burn(ownerOf(_tokenId), _tokenId);
  }

  function setTokenURI(uint256 _tokenId, string _uri) onlyOwnerOrSuperuser public {
    super._setTokenURI(_tokenId, _uri);
  }
}
