pragma solidity ^0.4.24;

/**
 * @title -airdrop Interface
 */

interface IAirdrop {

  function isVerifiedUser(address user) external view returns (bool);
  function isCollected(address user, bytes32 airdropId) external view returns (bool);
  function getAirdropIds()external view returns(bytes32[]);
  function getAirdropIdsByContractAddress(address contractAddress)external view returns(bytes32[]);
  function tokenTotalClaim(address contractAddress)external view returns(uint256);
  function getUser(address userAddress) external view returns (
    address,
    string,
    uint256,
    uint256
  );
  function getAirdrop(
    bytes32 airdropId
    ) external view returns (address, uint256, bool);
  function updateVeifyFee(uint256 fee) external;
  function verifyUser(string name) external payable;
  function addAirdrop (address contractAddress, uint256 countPerUser, bool needVerifiedUser) external;
  function claim(bytes32 airdropId) external;
  function withdrawToken(address contractAddress, address to) external;
  function withdrawEth(address to) external;

  
  

  /* Events */

  event UpdateVeifyFee (
    uint256 indexed fee
  );

  event VerifyUser (
    address indexed user
  );

  event AddAirdrop (
    address indexed contractAddress,
    uint256 countPerUser,
    bool needVerifiedUser
  );

  event Claim (
    bytes32 airdropId,
    address user
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
}
