pragma solidity ^0.4.24;

/**
 * @title -luckyblock Interface
 */

interface ILuckyblock{

  function getLuckyblockSpend(
    bytes32 luckyblockId
  ) external view returns (
    address[],
    uint256[],
    uint256
  ); 

  function getLuckyblockEarn(
    bytes32 luckyblockId
    ) external view returns (
    address[],
    uint256[],
    int[],
    uint256,
    int
  );

  function getLuckyblockBase(
    bytes32 luckyblockId
    ) external view returns (
      bool
  );

  function addLuckyblock(uint256 seed) external;

  function start(
    bytes32 luckyblockId
  ) external;

  function stop(
    bytes32 luckyblockId
  ) external;

  function updateLuckyblockSpend(
    bytes32 luckyblockId,
    address[] spendTokenAddresses, 
    uint256[] spendTokenCount,
    uint256 spendEtherCount
  ) external;

  function updateLuckyblockEarn (
    bytes32 luckyblockId,
    address[] earnTokenAddresses,
    uint256[] earnTokenCount,
    int[] earnTokenProbability, // (0 - 100)
    uint256 earnEtherCount,
    int earnEtherProbability
  ) external;

  function getLuckyblockIds()external view returns(bytes32[]);
  function play(bytes32 luckyblockId) external payable;
  function withdrawToken(address contractAddress, address to, uint256 balance) external;
  function withdrawEth(address to, uint256 balance) external;

  
  

  /* Events */

  event Play (
    bytes32 indexed luckyblockId,
    address user,
    uint8 random
  );

  event WithdrawToken (
    address indexed contractAddress,
    address to,
    uint256 count
  );

  event WithdrawEth (
    address to,
    uint256 count
  );

  event Pay (
    address from,
    uint256 value
  );
}