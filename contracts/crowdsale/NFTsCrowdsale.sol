pragma solidity ^0.4.24;

/**
 * @title -NFTs crowdsale
 * NFTsCrowdsale provides a marketplace for NFTs
 *
 *  ██████╗ ██████╗   ██████╗  ██╗    ██╗ ██████╗  ███████╗  █████╗  ██╗      ███████╗ ██╗
 * ██╔════╝ ██╔══██╗ ██╔═══██╗ ██║    ██║ ██╔══██╗ ██╔════╝ ██╔══██╗ ██║      ██╔════╝ ██║
 * ██║      ██████╔╝ ██║   ██║ ██║ █╗ ██║ ██║  ██║ ███████╗ ███████║ ██║      █████╗   ██║
 * ██║      ██╔══██╗ ██║   ██║ ██║███╗██║ ██║  ██║ ╚════██║ ██╔══██║ ██║      ██╔══╝   ╚═╝
 * ╚██████╗ ██║  ██║ ╚██████╔╝ ╚███╔███╔╝ ██████╔╝ ███████║ ██║  ██║ ███████╗ ███████╗ ██╗
 *  ╚═════╝ ╚═╝  ╚═╝  ╚═════╝   ╚══╝╚══╝  ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚══════╝ ╚══════╝ ╚═╝
 *
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * game at https://lordless.io
 * code at https://github.com/lordlessio
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
   * @dev batch New Auctions 
   * @param prices Array price in wei
   * @param tokenIds Array LDB's tokenid
   * @param endAts  Array auction end time
   */
  function batchNewAuctions(uint128[] prices, uint256[] tokenIds, uint256[] endAts) whenNotPaused external {
    uint256 i = 0;
    while (i < tokenIds.length) {
      _newAuction(prices[i], tokenIds[i], endAts[i]);
      i += 1;
    }
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

  /**
   * @dev batch cancel auctions
   * @param tokenIds Array LDB's tokenid
   */
  function batchCancelAuctions (uint256[] tokenIds) external {
    uint256 i = 0;
    while (i < tokenIds.length) {
      _cancelAuction(tokenIds[i]);
      i += 1;
    }
  }
}
