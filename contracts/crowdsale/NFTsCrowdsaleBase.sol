pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract NFTsCrowdsaleBase is Superuser {

  using SafeMath for uint256;

  ERC20 public erc20Contract;
  ERC721 public erc721Contract;
  // eth(price)/erc20(price)
  uint public eth2erc20;
  // Represents a auction on LDB Crowdsale
  struct Auction {
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
  
   /* Events */

  event NewAuction (
    address indexed seller,
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event PayByEthSuccess (
    address indexed seller,
    address indexed buyer,
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event PayByErc20Success (
    address indexed seller,
    address indexed buyer, 
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event CancelAuction (
    address indexed seller,
    uint256 indexed tokenId
  );

  constructor(address _erc721Address,address _erc20Address, uint _eth2erc20) public {
    erc721Contract = ERC721(_erc721Address);
    erc20Contract = ERC20(_erc20Address);
    eth2erc20 = _eth2erc20;
  }

  function getAuction(uint256 _tokenId) external view
  returns (
    address,
    uint256,
    uint256,
    uint256
  ){
    Auction storage auction = tokenIdToAuction[_tokenId];
    return (auction.seller, auction.price, auction.endAt, auction.tokenId);
  }

  function isOnAuction(uint256 _tokenId) public view returns (bool) {
    Auction storage _auction = tokenIdToAuction[_tokenId];
    return (_auction.endAt > now);
  }

  function _isTokenOwner(address _seller, uint256 _tokenId) internal view returns (bool){
    return (erc721Contract.ownerOf(_tokenId) == _seller);
  }

  function _escrow(address _owner, uint256 _tokenId) internal {
    erc721Contract.transferFrom(_owner, this, _tokenId);
  }

  function _transfer(address _receiver, uint256 _tokenId) internal {
    erc721Contract.safeTransferFrom(this, _receiver, _tokenId);
  }

  function _newAuction(uint256 _price, uint256 _tokenId, uint256 _endAt) internal {
    require(_price == uint256(_price));
    address _seller = msg.sender;

    require(_isTokenOwner(_seller, _tokenId));
    _escrow(_seller, _tokenId);

    Auction memory _order = Auction(
      _seller,
      uint128(_price),
      _endAt,
      _tokenId
    );

    tokenIdToAuction[_tokenId] = _order;
    emit NewAuction(_seller, _price, _endAt, _tokenId);
  }

  function _cancelAuction(uint256 _tokenId) internal {
    address tokenOwner = erc721Contract.ownerOf(_tokenId);
    require(tokenOwner == msg.sender || msg.sender == owner);
    Auction storage _auction = tokenIdToAuction[_tokenId];
    emit CancelAuction(_auction.seller, _tokenId);
    delete tokenIdToAuction[_tokenId];
  }

  function _payByEth(uint256 _tokenId) internal {
    uint256 _ethAmount = msg.value;
    Auction storage _auction = tokenIdToAuction[_tokenId];
    uint256 price = _auction.price;
    uint256 computedEthPrice = price.div(eth2erc20);
    require(isOnAuction(_auction.tokenId));
    require(_ethAmount >= computedEthPrice);

    uint256 payExcess = _ethAmount.sub(computedEthPrice);

    if (price > 0) {
      _auction.seller.transfer(computedEthPrice);
    }
    address buyer = msg.sender;
    buyer.transfer(payExcess);
    _transfer(buyer, _tokenId);
    emit PayByEthSuccess(_auction.seller, msg.sender, _auction.price, _auction.endAt, _auction.tokenId);
    delete tokenIdToAuction[_tokenId];
  }

  function _payByErc20(uint256 _tokenId) internal {

    Auction storage _auction = tokenIdToAuction[_tokenId];
    uint256 price = uint256(_auction.price);
    uint256 balance = erc20Contract.balanceOf(msg.sender);
    require(balance >= price);
    require(isOnAuction(_auction.tokenId));

    if (price > 0) {
      erc20Contract.transferFrom(msg.sender, _auction.seller, price);
    }
    _transfer(msg.sender, _tokenId);
    emit PayByErc20Success(_auction.seller, msg.sender, _auction.price, _auction.endAt, _auction.tokenId);
    delete tokenIdToAuction[_tokenId];
  }
  
}