pragma solidity ^0.4.24;

import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
import "./ITavernNFTs.sol";
/**
 * @title TavernNFTs - LORDLESS tavern NFTs Contract
 * TavernNFTs records the relationship of Tavern ownership.
 * 
 * ████████╗  █████╗  ██╗   ██╗ ███████╗ ██████╗  ███╗   ██╗ ███╗   ██╗ ███████╗ ████████╗ ███████╗ ██╗
 * ╚══██╔══╝ ██╔══██╗ ██║   ██║ ██╔════╝ ██╔══██╗ ████╗  ██║ ████╗  ██║ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██║
 *    ██║    ███████║ ██║   ██║ █████╗   ██████╔╝ ██╔██╗ ██║ ██╔██╗ ██║ █████╗      ██║    ███████╗ ██║
 *    ██║    ██╔══██║ ╚██╗ ██╔╝ ██╔══╝   ██╔══██╗ ██║╚██╗██║ ██║╚██╗██║ ██╔══╝      ██║    ╚════██║ ╚═╝
 *    ██║    ██║  ██║  ╚████╔╝  ███████╗ ██║  ██║ ██║ ╚████║ ██║ ╚████║ ██║         ██║    ███████║ ██╗
 *    ╚═╝    ╚═╝  ╚═╝   ╚═══╝   ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝  ╚═══╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝
 *
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * game at https://lordless.io
 * code at https://github.com/lordlessio
 */

interface TavernInterface {
  function tavern(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256);
}

contract TavernNFTs is ERC721Token, Superuser, ITavernNFTs {
  constructor(string name, string symbol) public
    ERC721Token(name, symbol)
  { }

  TavernInterface public tavernContract;
  uint16 public constant MAX_SUPPLY = 4000;  // Tavern MAX SUPPLY

  /**
   * @dev set the Tavern contract address
   * @return tavern Tavern contract address
   */
  function setTavernContract(address tavern) onlySuperuser external {
    tavernContract = TavernInterface(tavern);
    emit SetTavernContract(tavern);
  }
  
  function mint(address to, uint256 tokenId) onlySuperuser public {
    require(tokenId < MAX_SUPPLY);
    super._mint(to, tokenId);
  }

  function batchMint(address[] tos, uint256[] tokenIds) onlySuperuser external {
    uint256 i = 0;
    while (i < tokenIds.length) {
      super._mint(tos[i], tokenIds[i]);
      i += 1;
    }
  }

  function burn(uint256 tokenId) onlySuperuser public {
    super._burn(ownerOf(tokenId), tokenId);
  }
  
  /**
   * @dev Future use on ipfs or other decentralized storage platforms
   */
  function setTokenURI(uint256 _tokenId, string _uri) onlyOwnerOrSuperuser public {
    super._setTokenURI(_tokenId, _uri);
  }

  /**
   * @dev get a Tavern's infomation 
   * @param tokenId tokenId
   * @return uint256 Tavern's construction time
   * @return int Tavern's longitude value 
   * @return int Tavern's latitude value
   * @return uint8 Tavern's popularity
   * @return uint256 Tavern's activeness
   */
  function tavern(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256){
    return tavernContract.tavern(tokenId);
  }

}
