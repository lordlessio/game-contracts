pragma solidity ^0.4.24;

/**
 * @title -airdrop Interface
 */

interface IAirdrop_2 {

  function getAirdropSpend(
    bytes32 airdropId
  ) external view returns (
    address[],
    uint256[],
    uint256
  ); 

  function getAirdropEarn(
    bytes32 airdropId
    ) external view returns (
    address[],
    uint256[],
    int[],
    uint256,
    int
  );

  function getAirdropBase(
    bytes32 airdropId
    ) external view returns (
      bool
  );

  function addAirdrop(uint256 seed) external;

  function start(
    bytes32 airdropId
  ) external;

  function stop(
    bytes32 airdropId
  ) external;

  function updateAirdropSpend(
    bytes32 airdropId,
    address[] spendTokenAddresses, 
    uint256[] spendTokenCount,
    uint256 spendEtherCount
  ) external;

  function updateAirdropEarn (
    bytes32 airdropId,
    address[] earnTokenAddresses,
    uint256[] earnTokenCount,
    int[] earnTokenProbability, // (0 - 100)
    uint256 earnEtherCount,
    int earnEtherProbability
  ) external;

  function getAirdropIds()external view returns(bytes32[]);
  function claim(bytes32 airdropId) external payable;
  function withdrawToken(address contractAddress, address to, uint256 balance) external;
  function withdrawEth(address to, uint256 balance) external;

  
  

  /* Events */

  event Claim (
    bytes32 indexed airdropId,
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