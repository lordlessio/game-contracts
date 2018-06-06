pragma solidity ^0.4.21;


import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./EthPausable.sol";

contract NftCrowdsaleBase {

  using SafeMath for uint256;

  ERC20 public erc20Contract;
  ERC721 public erc721Contract;
  // eth(price)/erc20(price)
  uint public eth2erc20;
  // Represents a order on LDB Crowdsale
  struct Order {
    // Seller of LDB 
    address seller;
    // erc20 price(wei) of LDB
    uint256 price;
    //  Order startAt
    uint64 startAt;
    //  tokenId at ERC721 contract (erc721Contract)
    uint256 tokenId;
  }

  function NftCrowdsaleBase(address _erc721Address,address _erc20Address, uint _eth2erc20) public {
    erc721Contract = ERC721(_erc721Address);
    erc20Contract = ERC20(_erc20Address);
    eth2erc20 = _eth2erc20;
  }

  mapping (uint256 => Order) tokenIdToOrder;

  function _isOwner(address owner, uint256 _tokenId) internal view returns (bool){
    return (erc721Contract.ownerOf(_tokenId) == owner);
  }

  function _escrow(address _owner, uint256 _tokenId) internal {
    erc721Contract.transferFrom(_owner, this, _tokenId);
  }

  function _transfer(address _receiver, uint256 _tokenId) internal {
    erc721Contract.safeTransferFrom(this, _receiver, _tokenId);
  }

  function _newSale(uint256 _tokenId, Order _order) internal {
    tokenIdToOrder[_tokenId] = _order;
  }

  function _cancelOrder(uint256 _tokenId, address _seller) internal {
    // _removeOrder(_tokenId);
    _transfer(_seller, _tokenId);
  }

  function _defrayByEth(uint256 _tokenId, uint256 _ethAmount) internal {

    Order storage order = tokenIdToOrder[_tokenId];
    uint256 price = order.price;
    uint256 computedEthPrice = price.div(eth2erc20);
    require(_isOnSale(order));
    require(_ethAmount >= computedEthPrice);

    uint256 defrayExcess = _ethAmount.sub(computedEthPrice);

    if(price > 0) {
      order.seller.transfer(computedEthPrice);
    }
    msg.sender.transfer(defrayExcess);
 
  }

  function _defrayByErc20(uint256 _tokenId) internal {

    Order storage order = tokenIdToOrder[_tokenId];
    uint256 price = uint256(order.price);
    uint256 balance = erc20Contract.balanceOf(msg.sender);
    require( balance >= price);
    require(_isOnSale(order));

    if(price > 0) {
      erc20Contract.transferFrom(msg.sender, order.seller, price);
    }
  }

  function _isOnSale(Order storage _order) internal view returns (bool) {
    return (_order.startAt > 0);
  }
}

contract LdbNFTCrowdsale is NftCrowdsaleBase, Ownable, EthPausable, Pausable{

  function () external payable {
  }

  function LdbNFTCrowdsale(address _erc721Address, address _erc20Address, uint _eth2erc20) public 
  NftCrowdsaleBase(_erc721Address, _erc20Address, _eth2erc20){}

  function withdrawBalance() external {
    require(msg.sender == owner);
    owner.transfer(this.balance);
  }

  function newSale(uint128 _price, uint256 _tokenId) whenNotPaused external {

    require(_price == uint256(uint128(_price)));

    address _seller = msg.sender;

    require(_isOwner(_seller, _tokenId));

    _escrow(_seller, _tokenId);

    
    Order memory _order = Order(
      _seller,
      uint128(_price),
      uint64(now),
      _tokenId
    );

    tokenIdToOrder[_tokenId] = _order;
  }

  /**
   * @dev defray a order by eth
   * @param _tokenId ldb tokenid
   */
  function defrayByEth (uint256 _tokenId) whenNotEthPaused external payable {
    _defrayByEth(_tokenId, msg.value);
    _transfer(msg.sender, _tokenId);
  }

  /**
   * @dev defray a order by erc20 Token
   * @param _tokenId ldb tokenid
   */
  function defrayByErc20 (uint256 _tokenId) whenNotPaused external payable{
    _defrayByErc20(_tokenId);
    _transfer(msg.sender, _tokenId);
  }

  /**
   * @dev get a order detail by _tokenId
   * @param _tokenId ldb tokenid
   */

  function getOrder(uint256 _tokenId) external view
  returns (
    address seller,
    uint256 price,
    uint64 startAt,
    uint256 tokenId
  ){
    Order storage order = tokenIdToOrder[_tokenId];
    require(_isOnSale(order));
    seller = order.seller;
    price = order.price;
    startAt = order.startAt;
    tokenId = order.tokenId;
  } 
}
