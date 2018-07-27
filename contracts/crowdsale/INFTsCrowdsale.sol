pragma solidity ^0.4.23;

/**
 * @title -NFTs crowdsale Interface
 */

interface INFTsCrowdsale {

  function getAuction(uint256 _tokenId) external view
  returns (
    address,
    uint256,
    uint256,
    uint256
  );

  function isOnAuction(uint256 _tokenId) external view returns (bool);

  function newAuction(uint128 _price, uint256 _tokenId, uint256 _endAt) external;

  function payByEth (uint256 _tokenId) external payable; 

  function payByErc20 (uint256 _tokenId) external;

  function cancelAuction (uint256 _tokenId) external;

  
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

}
