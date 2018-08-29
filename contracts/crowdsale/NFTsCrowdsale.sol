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

import "./Pausable.sol";
import "./NFTsCrowdsaleBase.sol";


contract NFTsCrowdsale is NFTsCrowdsaleBase, Pausable {

  constructor(address erc721Address, address erc20Address, uint eth2erc20) public 
  NFTsCrowdsaleBase(erc721Address, erc20Address, eth2erc20){}

  /**
   * @dev new a Auction
   * @param price price in wei
   * @param tokenId Tavern's tokenid
   * @param endAt auction end time
   */
  function newAuction(uint128 price, uint256 tokenId, uint256 startAt, uint256 endAt) whenNotPaused external {
    uint256 _startAt = startAt;
    if (msg.sender != owner) {
      _startAt = block.timestamp;
    }
    _newAuction(price, tokenId, _startAt, endAt);
  }

  /**
   * @dev batch New Auctions 
   * @param prices Array price in wei
   * @param tokenIds Array Tavern's tokenid
   * @param endAts  Array auction end time
   */
  function batchNewAuctions(uint128[] prices, uint256[] tokenIds, uint256[] startAts, uint256[] endAts) whenNotPaused external {
    uint256 i = 0;
    while (i < tokenIds.length) {
      _newAuction(prices[i], tokenIds[i], startAts[i], endAts[i]);
      i += 1;
    }
  }

  /**
   * @dev pay a auction by eth
   * @param tokenId tavern tokenid
   */
  function payByEth (uint256 tokenId) whenNotPaused external payable {
    _payByEth(tokenId); 
  }

  /**
   * @dev pay a auction by erc20 Token
   * @param tokenId Tavern's tokenid
   */
  function payByErc20 (uint256 tokenId) whenNotPaused2 external {
    _payByErc20(tokenId);
  }

  /**
   * @dev cancel a auction
   * @param tokenId Tavern's tokenid
   */
  function cancelAuction (uint256 tokenId) external {
    _cancelAuction(tokenId);
  }

  /**
   * @dev batch cancel auctions
   * @param tokenIds Array Tavern's tokenid
   */
  function batchCancelAuctions (uint256[] tokenIds) external {
    uint256 i = 0;
    while (i < tokenIds.length) {
      _cancelAuction(tokenIds[i]);
      i += 1;
    }
  }
}
