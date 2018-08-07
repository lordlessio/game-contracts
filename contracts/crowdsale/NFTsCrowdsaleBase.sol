pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
import "../lib/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "./INFTsCrowdsale.sol";

contract NFTsCrowdsaleBase is Superuser, INFTsCrowdsale {

  using SafeMath for uint256;

  ERC20 public erc20Contract;
  ERC721 public erc721Contract;
  // eth(price)/erc20(price)
  uint public eth2erc20;
  // Represents a auction on LDB Crowdsale
  struct Auction {
    // Auction id
    bytes32 id;
    // Seller of LDB 
    address seller;
    // erc20 price(wei) of LDB
    uint256 price;
    //  Auction endAt
    uint256 endAt;
    //  tokenId at ERC721 contract (erc721Contract)
    uint256 tokenId;
  }

  mapping (uint256 => Auction) tokenIdToAuction;
  
  constructor(address _erc721Address,address _erc20Address, uint _eth2erc20) public {
    erc721Contract = ERC721(_erc721Address);
    erc20Contract = ERC20(_erc20Address);
    eth2erc20 = _eth2erc20;
  }

  function getAuction(uint256 _tokenId) external view
  returns (
    bytes32,
    address,
    uint256,
    uint256,
    uint256
  ){
    Auction storage auction = tokenIdToAuction[_tokenId];
    return (auction.id, auction.seller, auction.price, auction.endAt, auction.tokenId);
  }

  function isOnAuction(uint256 _tokenId) external view returns (bool) {
    Auction storage _auction = tokenIdToAuction[_tokenId];
    return (_auction.endAt > block.timestamp);
  }

  function _isTokenOwner(address _seller, uint256 _tokenId) internal view returns (bool){
    return (erc721Contract.ownerOf(_tokenId) == _seller);
  }

  function _isOnAuction(uint256 _tokenId) internal view returns (bool) {
    Auction storage _auction = tokenIdToAuction[_tokenId];
    return (_auction.endAt > block.timestamp);
  }
  function _escrow(address _owner, uint256 _tokenId) internal {
    erc721Contract.transferFrom(_owner, this, _tokenId);
  }

  function _cancelEscrow(address _owner, uint256 _tokenId) internal {
    erc721Contract.transferFrom(this, _owner, _tokenId);
  }

  function _transfer(address _receiver, uint256 _tokenId) internal {
    erc721Contract.safeTransferFrom(this, _receiver, _tokenId);
  }

  function _newAuction(uint256 _price, uint256 _tokenId, uint256 _endAt) internal {
    require(_price == uint256(_price));
    address _seller = msg.sender;

    require(_isTokenOwner(_seller, _tokenId));
    _escrow(_seller, _tokenId);

    bytes32 auctionId = keccak256(
      abi.encodePacked(block.timestamp, _seller, _tokenId, _price)
    );
    
    Auction memory _order = Auction(
      auctionId,
      _seller,
      uint128(_price),
      _endAt,
      _tokenId
    );

    tokenIdToAuction[_tokenId] = _order;
    emit NewAuction(auctionId, _seller, _price, _endAt, _tokenId);
  }

  function _cancelAuction(uint256 _tokenId) internal {
    address tokenOwner = erc721Contract.ownerOf(_tokenId);
    require(tokenOwner == msg.sender || msg.sender == owner);
    Auction storage _auction = tokenIdToAuction[_tokenId];
    emit CancelAuction(_auction.id, _auction.seller, _tokenId);
    _cancelEscrow(_auction.seller, _tokenId);
    delete tokenIdToAuction[_tokenId];
  }

  function _payByEth(uint256 _tokenId) internal {
    uint256 _ethAmount = msg.value;
    Auction storage _auction = tokenIdToAuction[_tokenId];
    uint256 price = _auction.price;
    require(_isOnAuction(_auction.tokenId));
    require(_ethAmount >= price);

    uint256 payExcess = _ethAmount.sub(price);

    if (price > 0) {
      _auction.seller.transfer(price);
    }
    address buyer = msg.sender;
    buyer.transfer(payExcess);
    _transfer(buyer, _tokenId);
    emit PayByEthSuccess(_auction.id, _auction.seller, msg.sender, _auction.price, _auction.endAt, _auction.tokenId);
    delete tokenIdToAuction[_tokenId];
  }

  function _payByErc20(uint256 _tokenId) internal {

    Auction storage _auction = tokenIdToAuction[_tokenId];
    uint256 price = uint256(_auction.price);
    uint256 computedErc20Price = price.mul(eth2erc20);
    uint256 balance = erc20Contract.balanceOf(msg.sender);
    require(balance >= computedErc20Price);
    require(_isOnAuction(_auction.tokenId));

    if (price > 0) {
      erc20Contract.transferFrom(msg.sender, _auction.seller, computedErc20Price);
    }
    _transfer(msg.sender, _tokenId);
    emit PayByErc20Success(_auction.id, _auction.seller, msg.sender, _auction.price, _auction.endAt, _auction.tokenId);
    delete tokenIdToAuction[_tokenId];
  }
  
}