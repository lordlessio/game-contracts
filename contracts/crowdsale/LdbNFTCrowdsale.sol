pragma solidity ^0.4.21;

import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable () public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


contract NftCrowdsaleBase {

  // Represents a order on LDB Crowdsale
  struct Order {
    // Seller of LDB 
    address seller;
    //  Price(wei) of LDB
    uint128 price;
    //  Order startAt
    uint64 startAt;
    //  tokenId at ERC721 contract (nftContract)
    uint256 tokenId;
  }

  ERC721 public nftContract;

  mapping (uint256 => Order) tokenIdToOrder;

  function _isOwner(address owner, uint256 _tokenId) internal view returns (bool){
    return (nftContract.ownerOf(_tokenId) == owner);
  }

  function _escrow(address _owner, uint256 _tokenId) internal {
    nftContract.transferFrom(_owner, this, _tokenId);
  }

  function _transfer(address _receiver, uint256 _tokenId) internal {
    nftContract.safeTransferFrom(this, _receiver, _tokenId);
  }

  function _newSale(uint256 _tokenId, Order _order) internal {
    tokenIdToOrder[_tokenId] = _order;
  }

  function _cancelOrder(uint256 _tokenId, address _seller) internal {
    _removeOrder(_tokenId);
    _transfer(_seller, _tokenId);
  }

  function _removeOrder(uint256 _tokenId) internal {
    delete tokenIdToOrder[_tokenId];
  }

  function _defray(uint256 _tokenId, uint256 _amount) internal {

    Order storage order = tokenIdToOrder[_tokenId];
    uint256 price = uint256(order.price);

    require(_isOnSale(order));
    require(_amount >= price);

    uint256 defrayExcess = _amount - price;

    if(price > 0) {
      order.seller.transfer(price);
    }
    msg.sender.transfer(defrayExcess);
 
  }

  function _isOnSale(Order storage _order) internal view returns (bool) {
    return (_order.startAt > 0);
  }
}

contract LdbNFTCrowdsale is NftCrowdsaleBase, Ownable{

  //  TODO:
  // bytes4 constant InterfaceSignature_ERC721 = bytes4(0x);  

  function () external payable {
  }

  function LdbNFTCrowdsale(address _nftAddress) public {
    ERC721 _nftCntract = ERC721(_nftAddress);
    nftContract = _nftCntract;
  }

  function withdrawBalance() external {
    require(msg.sender == owner);
    owner.transfer(this.balance);
  }

  function newSale(uint128 _price, uint256 _tokenId) external {

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
   * @dev defray a order 
   * @param _tokenId ldb tokenid
   */
  function defray (uint256 _tokenId) external payable{
    _defray(_tokenId, msg.value);
    _transfer(msg.sender, _tokenId);
  }

  /**
   * @dev get a order detail by _tokenId
   * @param _tokenId ldb tokenid
   */

  function getOrder(uint256 _tokenId) external view
  returns (
    address seller,
    uint128 price,
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
