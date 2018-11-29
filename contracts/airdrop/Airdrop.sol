pragma solidity ^0.4.24;

/**
 * @title -Airdrop
 * every erc20 token can doAirdrop here 
 * Contact us for further cooperation support@lordless.io
 *
 *  █████╗  ██╗ ██████╗  ██████╗  ██████╗   ██████╗  ██████╗
 * ██╔══██╗ ██║ ██╔══██╗ ██╔══██╗ ██╔══██╗ ██╔═══██╗ ██╔══██╗
 * ███████║ ██║ ██████╔╝ ██║  ██║ ██████╔╝ ██║   ██║ ██████╔╝
 * ██╔══██║ ██║ ██╔══██╗ ██║  ██║ ██╔══██╗ ██║   ██║ ██╔═══╝
 * ██║  ██║ ██║ ██║  ██║ ██████╔╝ ██║  ██║ ╚██████╔╝ ██║
 * ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═╝ ╚═════╝  ╚═╝  ╚═╝  ╚═════╝  ╚═╝
 *
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * game at http://lordless.games
 * code at https://github.com/lordlessio
 */

import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../lib/SafeMath.sol";
import "./IAirdrop.sol";

contract ERC20Interface {
  function transfer(address to, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function balanceOf(address tokenOwner) public view returns (uint balance);
}
contract Airdrop is Superuser, Pausable, IAirdrop {

  using SafeMath for *;

  struct User {
    address user;
    string name;
    uint256 verifytime;
    uint256 verifyFee;
  }

  struct Airdrop {
    address contractAddress;
    uint256 countPerUser; // wei
    bool needVerifiedUser;
  }

  uint256 public verifyFee = 2e16; // 0.02 eth
  bytes32[] public airdropIds; //

  mapping (address => User) public userAddressToUser;
  mapping (address => bytes32[]) contractAddressToAirdropId;
  mapping (bytes32 => Airdrop) airdropIdToAirdrop;
  mapping (bytes32 => mapping (address => bool)) airdropIdToUserAddress;
  mapping (address => uint256) contractAddressToAirdropCount;


  function isVerifiedUser(address user) external view returns (bool){
    return userAddressToUser[user].user == user;
  }

  function isCollected(address user, bytes32 airdropId) external view returns (bool) {
    return airdropIdToUserAddress[airdropId][user];
  }

  function getAirdropIdsByContractAddress(address contractAddress)external view returns(bytes32[]){
    return contractAddressToAirdropId[contractAddress];
  }
  function getAirdropIds()external view returns(bytes32[]){
    return airdropIds;
  }

  function tokenTotalClaim(address contractAddress)external view returns(uint256){
    return contractAddressToAirdropCount[contractAddress];
  }

  function getUser(
    address userAddress
    ) external view returns (address, string, uint256 ,uint256){
    User storage user = userAddressToUser[userAddress];
    return (user.user, user.name, user.verifytime, user.verifyFee);
  }

  function getAirdrop(
    bytes32 airdropId
    ) external view returns (address, uint256, bool){
    Airdrop storage airdrop = airdropIdToAirdrop[airdropId];
    return (airdrop.contractAddress, airdrop.countPerUser, airdrop.needVerifiedUser);
  }
  
  function updateVeifyFee(uint256 fee) external onlyOwnerOrSuperuser{
    verifyFee = fee;
    emit UpdateVeifyFee(fee);
  }

  function verifyUser(string name) external payable whenNotPaused {
    address sender = msg.sender;
    require(!this.isVerifiedUser(sender), "Is Verified User");
    uint256 _ethAmount = msg.value;
    require(_ethAmount >= verifyFee, "LESS FEE");
    uint256 payExcess = _ethAmount.sub(verifyFee);
    if(payExcess > 0) {
      sender.transfer(payExcess);
    }
    
    User memory _user = User(
      sender,
      name,
      block.timestamp,
      verifyFee
    );

    userAddressToUser[sender] = _user;
    emit VerifyUser(msg.sender);
  }

  function addAirdrop(address contractAddress, uint256 countPerUser, bool needVerifiedUser) external onlyOwnerOrSuperuser{
    bytes32 airdropId = keccak256(
      abi.encodePacked(block.timestamp, contractAddress, countPerUser, needVerifiedUser)
    );

    Airdrop memory _airdrop = Airdrop(
      contractAddress,
      countPerUser,
      needVerifiedUser
    );
    airdropIdToAirdrop[airdropId] = _airdrop;
    airdropIds.push(airdropId);
    contractAddressToAirdropId[contractAddress].push(airdropId);
    emit AddAirdrop(contractAddress, countPerUser, needVerifiedUser);
  }

  function claim(bytes32 airdropId) external whenNotPaused {

    Airdrop storage _airdrop = airdropIdToAirdrop[airdropId];
    if (_airdrop.needVerifiedUser) {
      require(this.isVerifiedUser(msg.sender));
    }
    
    require(!this.isCollected(msg.sender, airdropId), "The same Airdrop can only be collected once per address.");
    ERC20Interface erc20 = ERC20Interface(_airdrop.contractAddress);
    erc20.transfer(msg.sender, _airdrop.countPerUser);
    airdropIdToUserAddress[airdropId][msg.sender] = true;
    // update to
    contractAddressToAirdropCount[_airdrop.contractAddress] = 
      contractAddressToAirdropCount[_airdrop.contractAddress].add(_airdrop.countPerUser);
    emit Claim(airdropId, msg.sender);
  }

  function withdrawToken(address contractAddress, address to) external onlyOwnerOrSuperuser {
    ERC20Interface erc20 = ERC20Interface(contractAddress);
    uint256 balance = erc20.balanceOf(address(this));
    erc20.transfer(to, balance);
    emit WithdrawToken(contractAddress, to, balance);
  }

  function withdrawEth(address to) external onlySuperuser {
    uint256 balance = address(this).balance;
    to.transfer(balance);
    emit WithdrawEth(to, balance);
  }

}
