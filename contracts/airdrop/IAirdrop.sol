pragma solidity ^0.4.24;

/**
 * @title -airdrop Interface
 */

interface IAirdrop {

  function isVeifiedUser(address user) external view returns (bool);
  function isCollected(address user, bytes32 contractAddress) external view returns (bool);
  function getAirdropIds()external view returns(bytes32[]);
  function getAirdropIdsByContractAddress(address contractAddress)external view returns(bytes32[]);
  function getUser(address userAddress) external view returns (
    address,
    string,
    uint256,
    uint256
  );
  function getAirdrop(
    bytes32 airdropId
    ) external view returns (address, uint256, bool, uint256);
  function updateVeifyFee(uint256 fee) external;
  function verifyUser(string name) external payable;
  function addAirdrop (address contractAddress, uint256 countPerUser, bool needVerifiedUser, uint256 endAt) external;
  function collectAirdrop(bytes32 airdropId) external;
  function withdrawToken(address contractAddress, address to) external;
  function withdrawEth(address to) external;

  
  

  /* Events */

  event UpdateVeifyFee (
    address indexed user
  );

  event VerifyUser (
    address indexed user
  );

  event AddToken (
    address indexed token,
    uint256 countPerUser,
    bool needVerifiedUser
  );

  event UpdateToken (
    address indexed token,
    uint256 countPerUser,
    bool needVerifiedUser
  );

  event DeleteToken (
    address indexed token
  );  

  event TransferToken (
    address indexed token,
    uint256 count
  );

  event WithdrawToken (
    address indexed token,
    address to,
    uint256 count
  );

  event WithdrawEth (
    address to,
    uint256 count
  );
}
