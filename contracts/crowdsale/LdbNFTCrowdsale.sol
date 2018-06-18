pragma solidity ^0.4.23;


import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./EthDefaryPausable.sol";

contract NftCrowdsaleBase is Ownable {

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
  
   /* Event */

  constructor(address _erc721Address,address _erc20Address, uint _eth2erc20) public {
    erc721Contract = ERC721(_erc721Address);
    erc20Contract = ERC20(_erc20Address);
    eth2erc20 = _eth2erc20;
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

  function _newAuction(uint128 _price, uint256 _tokenId, uint256 _endAt) internal {
    require(_price == uint256(uint128(_price)));
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
  }

  function _cancelAuction(uint256 _tokenId, address _seller) internal {
    require(erc721Contract.ownerOf(_tokenId) == _seller || msg.sender == owner);
    _transfer(_seller, _tokenId);
    
  }

  function _defrayByEth(uint256 _tokenId) internal {
    uint256 _ethAmount = msg.value;
    Auction storage auction = tokenIdToAuction[_tokenId];
    uint256 price = auction.price;
    uint256 computedEthPrice = price.div(eth2erc20);
    require(_isOnAuction(auction));
    require(_ethAmount >= computedEthPrice);

    uint256 defrayExcess = _ethAmount.sub(computedEthPrice);

    if(price > 0) {
      auction.seller.transfer(computedEthPrice);
    }
    msg.sender.transfer(defrayExcess);
    _transfer(msg.sender, _tokenId);
    delete tokenIdToAuction[_tokenId];
  }

  function _defrayByErc20(uint256 _tokenId) internal {

    Auction storage auction = tokenIdToAuction[_tokenId];
    uint256 price = uint256(auction.price);
    uint256 balance = erc20Contract.balanceOf(msg.sender);
    require( balance >= price);
    require(_isOnAuction(auction));

    if(price > 0) {
      erc20Contract.transferFrom(msg.sender, auction.seller, price);
    }
    _transfer(msg.sender, _tokenId);
    delete tokenIdToAuction[_tokenId];
  }

  function _isOnAuction(Auction storage _auction) internal view returns (bool) {
    return (_auction.endAt > now);
  }

  function _cancelAuction(address _seller, uint256 _tokenId) internal {
    require(erc721Contract.ownerOf(_tokenId) == _seller || msg.sender == owner);
    delete tokenIdToAuction[_tokenId];
  }
}

contract LdbNFTCrowdsale is NftCrowdsaleBase, EthDefaryPausable, Pausable{

  function () external payable {}

  constructor(address _erc721Address, address _erc20Address, uint _eth2erc20) public 
  NftCrowdsaleBase(_erc721Address, _erc20Address, _eth2erc20){}

  function withdrawBalance() onlyOwner external {
    owner.transfer(this.balance);
  }

  function newAuction(uint128 _price, uint256 _tokenId, uint256 _endAt) whenNotPaused external {
    _newAuction(_price, _tokenId, _endAt);
  }

  /**
   * @dev defray a auction by eth
   * @param _tokenId ldb tokenid
   */
  function defrayByEth (uint256 _tokenId) whenNotEthPaused external payable {
    _defrayByEth(_tokenId); 
  }

  /**
   * @dev defray a auction by erc20 Token
   * @param _tokenId ldb tokenid
   */
  function defrayByErc20 (uint256 _tokenId) whenNotPaused external payable{
    _defrayByErc20(_tokenId);
  }

  /**
   * @dev cancel a auction
   * @param _tokenId ldb tokenid
   */
  function cancelAuction (uint256 _tokenId) whenNotPaused external payable{
    _cancelAuction(msg.sender, _tokenId);
  }

  /**
   * @dev get a auction detail by _tokenId
   * @param _tokenId ldb tokenid
   */

  function getAuction(uint256 _tokenId) external view
  returns (
    address seller,
    uint256 price,
    uint256 endAt,
    uint256 tokenId
  ){
    Auction storage auction = tokenIdToAuction[_tokenId];
    seller = auction.seller;
    price = auction.price;
    endAt = auction.endAt;
    tokenId = auction.tokenId;
  } 
}
