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
import "./IAirdrop_2.sol";

contract ERC20Interface {
  function transfer(address to, uint tokens) public returns (bool);
  function transferFrom(address from, address to, uint tokens) public returns (bool);
  function balanceOf(address tokenOwner) public view returns (uint256);
  function allowance(address tokenOwner, address spender) public view returns (uint);
}
contract Airdrop_2 is Superuser, Pausable, IAirdrop_2 {

  using SafeMath for *;

  struct User {
    address user;
    string name;
    uint256 verifytime;
    uint256 verifyFee;
  }

  struct AirdropBase {
    bool ended;
  }

  struct AirdropSpend {
    address[] spendTokenAddresses;
    uint256[] spendTokenCount;
    uint256 spendEtherCount;
  }

  struct AirdropEarn {
    address[] earnTokenAddresses;
    uint256[] earnTokenCount;
    int[] earnTokenProbability; // (0 - 100)
    uint256 earnEtherCount;
    int earnEtherProbability;
  }

  uint256 public verifyFee = 2e16; // 0.02 eth
  bytes32[] public airdropIds; //

  mapping (address => User) public userAddressToUser;
  mapping (address => bytes32[]) contractAddressToAirdropId;

  mapping (bytes32 => AirdropEarn) airdropIdToAirdropEarn;
  mapping (bytes32 => AirdropSpend) airdropIdToAirdropSpend;
  mapping (bytes32 => AirdropBase) airdropIdToAirdropBase;


  mapping (bytes32 => mapping (address => bool)) airdropIdToUserAddress;
  mapping (address => uint256) contractAddressToAirdropCount;

  function () public payable {
    emit Pay(msg.sender, msg.value);
  }

  function getAirdropIds()external view returns(bytes32[]){
    return airdropIds;
  }

  function getAirdropSpend(
    bytes32 airdropId
    ) external view returns (
      address[],
      uint256[],
      uint256
    ) {
    AirdropSpend storage _airdropSpend = airdropIdToAirdropSpend[airdropId];
    return (
      _airdropSpend.spendTokenAddresses,
      _airdropSpend.spendTokenCount,
      _airdropSpend.spendEtherCount
      );
  }

  function getAirdropEarn(
    bytes32 airdropId
    ) external view returns (
      address[],
      uint256[],
      int[],
      uint256,
      int
    ) {
    AirdropEarn storage _airdropEarn = airdropIdToAirdropEarn[airdropId];
    return (
      _airdropEarn.earnTokenAddresses,
      _airdropEarn.earnTokenCount,
      _airdropEarn.earnTokenProbability,
      _airdropEarn.earnEtherCount,
      _airdropEarn.earnEtherProbability
      );
  }

  function getAirdropBase(
    bytes32 airdropId
    ) external view returns (
      bool
    ) {
    AirdropBase storage _airdropBase = airdropIdToAirdropBase[airdropId];
    return (
      _airdropBase.ended
      );
  }
  
  function addAirdrop(uint256 seed) external onlyOwnerOrSuperuser {
    bytes32 airdropId = keccak256(
      abi.encodePacked(block.timestamp, seed)
    );
    AirdropBase memory _airdropBase = AirdropBase(
      false
    );
    airdropIds.push(airdropId);
    airdropIdToAirdropBase[airdropId] = _airdropBase;
  }

  function start(bytes32 airdropId) external{
    AirdropBase storage _airdropBase = airdropIdToAirdropBase[airdropId];
    _airdropBase.ended = false;
    airdropIdToAirdropBase[airdropId] = _airdropBase;
  }

  function stop(bytes32 airdropId) external{
    AirdropBase storage _airdropBase = airdropIdToAirdropBase[airdropId];
    _airdropBase.ended = true;
    airdropIdToAirdropBase[airdropId] = _airdropBase;
  }

  function updateAirdropSpend (
    bytes32 airdropId,
    address[] spendTokenAddresses, 
    uint256[] spendTokenCount,
    uint256 spendEtherCount
    ) external onlyOwnerOrSuperuser {
    AirdropSpend memory _airdropSpend = AirdropSpend(
      spendTokenAddresses,
      spendTokenCount,
      spendEtherCount
    );
    airdropIdToAirdropSpend[airdropId] = _airdropSpend;
  }

  function updateAirdropEarn (
    bytes32 airdropId,
    address[] earnTokenAddresses,
    uint256[] earnTokenCount,
    int[] earnTokenProbability, // (0 - 100)
    uint256 earnEtherCount,
    int earnEtherProbability
    ) external onlyOwnerOrSuperuser {
    AirdropEarn memory _airdropEarn = AirdropEarn(
      earnTokenAddresses,
      earnTokenCount,
      earnTokenProbability, // (0 - 100)
      earnEtherCount,
      earnEtherProbability
    );
    airdropIdToAirdropEarn[airdropId] = _airdropEarn;
  }


  function claim(bytes32 airdropId) external payable whenNotPaused {
    AirdropBase storage _airdropBase = airdropIdToAirdropBase[airdropId];
    AirdropSpend storage _airdropSpend = airdropIdToAirdropSpend[airdropId];
    AirdropEarn storage _airdropEarn = airdropIdToAirdropEarn[airdropId];
    
    require(!_airdropBase.ended, "airdrop is ended");

    // check spend
    for (uint8 i = 0; i < _airdropSpend.spendTokenAddresses.length; i++) {
      // check sender's erc20 balance 
      require(
        ERC20Interface(
          _airdropSpend.spendTokenAddresses[i]
        ).balanceOf(address(msg.sender)) >= _airdropSpend.spendTokenCount[i]
      );

      require(
        ERC20Interface(
          _airdropSpend.spendTokenAddresses[i]
        ).allowance(address(msg.sender), address(this)) >= _airdropSpend.spendTokenCount[i]
      );

      // transfer erc20 token
      ERC20Interface(_airdropEarn.earnTokenAddresses[i])
        .transferFrom(msg.sender, address(this), _airdropSpend.spendTokenCount[i]);
    }

    // check sender's ether balance 
    require(msg.value >= _airdropSpend.spendEtherCount, "sender value not enough");
    
    // check earn erc20
    for (uint8 j= 0; j < _airdropEarn.earnTokenAddresses.length; j++) {
      // check sender's erc20 balance 
      uint256 earnTokenCount = _airdropEarn.earnTokenCount[j];
      require(
        ERC20Interface(_airdropEarn.earnTokenAddresses[j])
        .balanceOf(address(this)) >= earnTokenCount
      );
    }
    // check earn ether
    require(address(this).balance >= _airdropEarn.earnEtherCount, "contract value not enough");

    // do a random
    uint8 _random = random();

    // earn erc20
    for (uint8 k = 0; k < _airdropEarn.earnTokenAddresses.length; k++){
      // if win erc20
      if (_random + _airdropEarn.earnTokenProbability[k] >= 100) {
        ERC20Interface(_airdropEarn.earnTokenAddresses[k])
          .transfer(msg.sender, _airdropEarn.earnTokenCount[k]);
      }
    }
    
    // if win ether
    if (_random + _airdropEarn.earnEtherProbability >= 100 ) {
      msg.sender.transfer(_airdropEarn.earnEtherCount);
    }

    emit Claim(airdropId, msg.sender, _random);
  }

  function withdrawToken(address contractAddress, address to, uint256 balance)
    external onlyOwnerOrSuperuser {
    ERC20Interface erc20 = ERC20Interface(contractAddress);
    if (balance == uint256(0x0)){
      erc20.transfer(to, erc20.balanceOf(address(this)));
      emit WithdrawToken(contractAddress, to, erc20.balanceOf(address(this)));
    } else {
      erc20.transfer(to, balance);
      emit WithdrawToken(contractAddress, to, balance);
    }
  }

  function withdrawEth(address to, uint256 balance) external onlySuperuser {
    if (balance == uint256(0x0)) {
      to.transfer(address(this).balance);
      emit WithdrawEth(to, address(this).balance);
    } else {
      to.transfer(balance);
      emit WithdrawEth(to, balance);
    }
  }

  function random() private view returns (uint8) {
    return uint8(uint256(keccak256(block.timestamp, block.difficulty))%100); // random 0-99
  }

}
 