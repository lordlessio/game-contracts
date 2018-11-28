pragma solidity ^0.4.24;

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
    uint256 endAt;
  }

  uint256 public verifyFee = 2e16; // 0.02 eth
  bytes32[] public airdropIds; //

  mapping (address => User) public userAddressToUser;
  mapping (address => bytes32[]) contractAddressToAirdropId;
  mapping (bytes32 => Airdrop) airdropIdToAirdrop;
  mapping (bytes32 => mapping (address => bool)) airdropIdToUserAddress;


  function isVeifiedUser(address user) external view returns (bool){
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
  function getUser(
    address userAddress
    ) external view returns (address, string, uint256 ,uint256){
    User storage user = userAddressToUser[userAddress];
    return (user.user, user.name, user.verifytime, user.verifyFee);
  }

  function getAirdrop(
    bytes32 airdropId
    ) external view returns (address, uint256, bool, uint256){
    Airdrop storage airdrop = airdropIdToAirdrop[airdropId];
    return (airdrop.contractAddress, airdrop.countPerUser, airdrop.needVerifiedUser, airdrop.endAt);
  }
  
  function updateVeifyFee(uint256 fee) external onlyOwnerOrSuperuser{
    verifyFee = fee;
  }

  function verifyUser(string name) external payable {
    require(this.isVeifiedUser(sender), "Is Veified User");
    uint256 _ethAmount = msg.value;
    address sender = msg.sender;
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
  }

  function addAirdrop(address contractAddress, uint256 countPerUser, bool needVerifiedUser, uint256 endAt) external onlyOwnerOrSuperuser{
    bytes32 airdropId = keccak256(
      abi.encodePacked(block.timestamp, contractAddress, countPerUser, needVerifiedUser)
    );

    Airdrop memory _airdrop = Airdrop(
      contractAddress,
      countPerUser,
      needVerifiedUser,
      endAt
    );
    airdropIdToAirdrop[airdropId] = _airdrop;
    airdropIds.push(airdropId);
    contractAddressToAirdropId[contractAddress].push(airdropId);
    
  }

  function collectAirdrop(bytes32 airdropId) external {

    Airdrop storage _airdrop = airdropIdToAirdrop[airdropId];
    if (_airdrop.needVerifiedUser) {
      require(this.isVeifiedUser(msg.sender));
    }
    
    require(!this.isCollected(msg.sender, airdropId), "The same Airdrop can only be collected once per address.");
    ERC20Interface erc20 = ERC20Interface(_airdrop.contractAddress);
    erc20.transfer(msg.sender, _airdrop.countPerUser);
    airdropIdToUserAddress[airdropId][msg.sender] = true;
  }

  function withdrawToken(address contractAddress, address to) external onlyOwnerOrSuperuser {
    ERC20Interface erc20 = ERC20Interface(contractAddress);
    erc20.transfer(to, erc20.balanceOf(address(this)));
  }

  function withdrawEth(address to) external onlySuperuser {
    to.transfer(address(this).balance);
  }

}
