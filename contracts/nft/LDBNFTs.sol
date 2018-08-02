pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
import "./ILDBNFTs.sol";
/**
 * @title LDBNFTs - LORDLESS BUILDING NFTs Contract
 * LDBNFTs records the relationship of LDB ownership.
 * 
 * ██╗      ██████╗  ██████╗  ███╗   ██╗ ███████╗ ████████╗ ███████╗ ██╗
 * ██║      ██╔══██╗ ██╔══██╗ ████╗  ██║ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██║
 * ██║      ██║  ██║ ██████╔╝ ██╔██╗ ██║ █████╗      ██║    ███████╗ ██║
 * ██║      ██║  ██║ ██╔══██╗ ██║╚██╗██║ ██╔══╝      ██║    ╚════██║ ╚═╝
 * ███████╗ ██████╔╝ ██████╔╝ ██║ ╚████║ ██║         ██║    ███████║ ██╗
 * ╚══════╝ ╚═════╝  ╚═════╝  ╚═╝  ╚═══╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝
 *
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * game at https://lordless.io
 * code at https://github.com/lordlessio
 */

interface BuildingInterface {
  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256);
  function isBuildingContract() external view returns (bool);
}

contract LDBNFTs is ERC721Token, Superuser, ILDBNFTs {
  constructor(string name, string symbol) public
    ERC721Token(name, symbol)
  { }

  BuildingInterface public buildingContract;

  function mint(address to, uint256 tokenId) onlySuperuser public {
    super._mint(to, tokenId);
  }

  function batchMint(address[] tos, uint256[] tokenIds) onlySuperuser public {
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
   * @dev set the LDB contract address
   * @return building LDB contract address
   */
  function setBuildingContract(address building) onlySuperuser external {
    require(BuildingInterface(building).isBuildingContract());
    buildingContract = BuildingInterface(building);
  }

  /**
   * @dev get a Building's infomation 
   * @param tokenId tokenId
   * @return uint256 LDB's construction time
   * @return int LDB's longitude value 
   * @return int LDB's latitude value
   * @return uint8 LDB's popularity
   * @return uint256 LDB's activeness
   */
  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256){
    return buildingContract.building(tokenId);
  }

}
