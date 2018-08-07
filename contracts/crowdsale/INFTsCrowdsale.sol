pragma solidity ^0.4.23;

/**
 * @title -NFTs crowdsale Interface
 */

interface INFTsCrowdsale {

  function getAuction(uint256 _tokenId) external view
  returns (
    bytes32,
    address,
    uint256,
    uint256,
    uint256
  );

  function isOnAuction(uint256 _tokenId) external view returns (bool);

  function newAuction(uint128 _price, uint256 _tokenId, uint256 _endAt) external;

  function batchNewAuctions(uint128[] prices, uint256[] tokenIds, uint256[] endAts) external;

  function payByEth (uint256 _tokenId) external payable; 

  function payByErc20 (uint256 _tokenId) external;

  function cancelAuction (uint256 _tokenId) external;

  function batchCancelAuctions (uint256[] tokenIds) external;
  
  /* Events */

  event NewAuction (
    bytes32 id,
    address indexed seller,
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event PayByEthSuccess (
    bytes32 id,
    address indexed seller,
    address indexed buyer,
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event PayByErc20Success (
    bytes32 id,
    address indexed seller,
    address indexed buyer, 
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event CancelAuction (
    bytes32 id,
    address indexed seller,
    uint256 indexed tokenId
  );

}
