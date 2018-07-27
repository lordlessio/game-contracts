pragma solidity ^0.4.23;

/**
 * @title -NFTs crowdsale
 *
 *  ██████╗ ██████╗   ██████╗  ██╗    ██╗ ██████╗  ███████╗  █████╗  ██╗      ███████╗ ██╗
 * ██╔════╝ ██╔══██╗ ██╔═══██╗ ██║    ██║ ██╔══██╗ ██╔════╝ ██╔══██╗ ██║      ██╔════╝ ██║
 * ██║      ██████╔╝ ██║   ██║ ██║ █╗ ██║ ██║  ██║ ███████╗ ███████║ ██║      █████╗   ██║
 * ██║      ██╔══██╗ ██║   ██║ ██║███╗██║ ██║  ██║ ╚════██║ ██╔══██║ ██║      ██╔══╝   ╚═╝
 * ╚██████╗ ██║  ██║ ╚██████╔╝ ╚███╔███╔╝ ██████╔╝ ███████║ ██║  ██║ ███████╗ ███████╗ ██╗
  * ╚═════╝ ╚═╝  ╚═╝  ╚═════╝   ╚══╝╚══╝  ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚══════╝ ╚══════╝ ╚═╝
 *
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 */

import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./EthPayPausable.sol";
import "./NFTsCrowdsaleBase.sol";


contract NFTsCrowdsale is NFTsCrowdsaleBase, EthPayPausable, Pausable{

  constructor(address erc721Address, address erc20Address, uint eth2erc20) public 
  NFTsCrowdsaleBase(erc721Address, erc20Address, eth2erc20){}

  /**
   * @dev new a Auction
   * @param price price in wei
   * @param tokenId LDB's tokenid
   * @param endAt auction end time
   */
  function newAuction(uint128 price, uint256 tokenId, uint256 endAt) whenNotPaused external {
    _newAuction(price, tokenId, endAt);
  }

  /**
   * @dev pay a auction by eth
   * @param tokenId ldb tokenid
   */
  function payByEth (uint256 tokenId) whenNotEthPaused external payable {
    _payByEth(tokenId); 
  }

  /**
   * @dev pay a auction by erc20 Token
   * @param tokenId LDB's tokenid
   */
  function payByErc20 (uint256 tokenId) whenNotPaused external {
    _payByErc20(tokenId);
  }

  /**
   * @dev cancel a auction
   * @param tokenId LDB's tokenid
   */
  function cancelAuction (uint256 tokenId) external {
    _cancelAuction(tokenId);
  }
}
