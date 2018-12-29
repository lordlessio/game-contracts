pragma solidity ^0.4.24;

/**
 * @title -Airdrop
 * play a luckyblock : )
 * Contact us for further cooperation support@lordless.io
 *
 * ██╗      ██╗   ██╗  ██████╗ ██╗  ██╗ ██╗   ██╗ ██████╗  ██╗       ██████╗   ██████╗ ██╗  ██╗
 * ██║      ██║   ██║ ██╔════╝ ██║ ██╔╝ ╚██╗ ██╔╝ ██╔══██╗ ██║      ██╔═══██╗ ██╔════╝ ██║ ██╔╝
 * ██║      ██║   ██║ ██║      █████╔╝   ╚████╔╝  ██████╔╝ ██║      ██║   ██║ ██║      █████╔╝
 * ██║      ██║   ██║ ██║      ██╔═██╗    ╚██╔╝   ██╔══██╗ ██║      ██║   ██║ ██║      ██╔═██╗
 * ███████╗ ╚██████╔╝ ╚██████╗ ██║  ██╗    ██║    ██████╔╝ ███████╗ ╚██████╔╝ ╚██████╗ ██║  ██╗
 * ╚══════╝  ╚═════╝   ╚═════╝ ╚═╝  ╚═╝    ╚═╝    ╚═════╝  ╚══════╝  ╚═════╝   ╚═════╝ ╚═╝  ╚═╝
 *
 * ---
 * POWERED BY
 * ╦   ╔═╗ ╦═╗ ╔╦╗ ╦   ╔═╗ ╔═╗ ╔═╗      ╔╦╗ ╔═╗ ╔═╗ ╔╦╗
 * ║   ║ ║ ╠╦╝  ║║ ║   ║╣  ╚═╗ ╚═╗       ║  ║╣  ╠═╣ ║║║
 * ╩═╝ ╚═╝ ╩╚═ ═╩╝ ╩═╝ ╚═╝ ╚═╝ ╚═╝       ╩  ╚═╝ ╩ ╩ ╩ ╩
 * game at https://game.lordless.io
 * code at https://github.com/lordlessio
 */

import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";
import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../lib/SafeMath.sol";
import "./ILuckyblock.sol";

contract ERC20Interface {
  function transfer(address to, uint tokens) public returns (bool);
  function transferFrom(address from, address to, uint tokens) public returns (bool);
  function balanceOf(address tokenOwner) public view returns (uint256);
  function allowance(address tokenOwner, address spender) public view returns (uint);
}
contract Luckyblock is Superuser, Pausable, ILuckyblock {

  using SafeMath for *;

  struct User {
    address user;
    string name;
    uint256 verifytime;
    uint256 verifyFee;
  }

  struct LuckyblockBase {
    bool ended;
  }

  struct LuckyblockSpend {
    address[] spendTokenAddresses;
    uint256[] spendTokenCount;
    uint256 spendEtherCount;
  }

  struct LuckyblockEarn {
    address[] earnTokenAddresses;
    uint256[] earnTokenCount;
    int[] earnTokenProbability; // (0 - 100)
    uint256 earnEtherCount;
    int earnEtherProbability;
  }

  bytes32[] public luckyblockIds; //

  mapping (address => bytes32[]) contractAddressToLuckyblockId;

  mapping (bytes32 => LuckyblockEarn) luckyblockIdToLuckyblockEarn;
  mapping (bytes32 => LuckyblockSpend) luckyblockIdToLuckyblockSpend;
  mapping (bytes32 => LuckyblockBase) luckyblockIdToLuckyblockBase;


  mapping (bytes32 => mapping (address => bool)) luckyblockIdToUserAddress;
  mapping (address => uint256) contractAddressToLuckyblockCount;

  function () public payable {
    emit Pay(msg.sender, msg.value);
  }

  function getLuckyblockIds()external view returns(bytes32[]){
    return luckyblockIds;
  }

  function getLuckyblockSpend(
    bytes32 luckyblockId
    ) external view returns (
      address[],
      uint256[],
      uint256
    ) {
    LuckyblockSpend storage _luckyblockSpend = luckyblockIdToLuckyblockSpend[luckyblockId];
    return (
      _luckyblockSpend.spendTokenAddresses,
      _luckyblockSpend.spendTokenCount,
      _luckyblockSpend.spendEtherCount
      );
  }

  function getLuckyblockEarn(
    bytes32 luckyblockId
    ) external view returns (
      address[],
      uint256[],
      int[],
      uint256,
      int
    ) {
    LuckyblockEarn storage _luckyblockEarn = luckyblockIdToLuckyblockEarn[luckyblockId];
    return (
      _luckyblockEarn.earnTokenAddresses,
      _luckyblockEarn.earnTokenCount,
      _luckyblockEarn.earnTokenProbability,
      _luckyblockEarn.earnEtherCount,
      _luckyblockEarn.earnEtherProbability
      );
  }

  function getLuckyblockBase(
    bytes32 luckyblockId
    ) external view returns (
      bool
    ) {
    LuckyblockBase storage _luckyblockBase = luckyblockIdToLuckyblockBase[luckyblockId];
    return (
      _luckyblockBase.ended
      );
  }
  
  function addLuckyblock(uint256 seed) external onlyOwnerOrSuperuser {
    bytes32 luckyblockId = keccak256(
      abi.encodePacked(block.timestamp, seed)
    );
    LuckyblockBase memory _luckyblockBase = LuckyblockBase(
      false
    );
    luckyblockIds.push(luckyblockId);
    luckyblockIdToLuckyblockBase[luckyblockId] = _luckyblockBase;
  }

  function start(bytes32 luckyblockId) external{
    LuckyblockBase storage _luckyblockBase = luckyblockIdToLuckyblockBase[luckyblockId];
    _luckyblockBase.ended = false;
    luckyblockIdToLuckyblockBase[luckyblockId] = _luckyblockBase;
  }

  function stop(bytes32 luckyblockId) external{
    LuckyblockBase storage _luckyblockBase = luckyblockIdToLuckyblockBase[luckyblockId];
    _luckyblockBase.ended = true;
    luckyblockIdToLuckyblockBase[luckyblockId] = _luckyblockBase;
  }

  function updateLuckyblockSpend (
    bytes32 luckyblockId,
    address[] spendTokenAddresses, 
    uint256[] spendTokenCount,
    uint256 spendEtherCount
    ) external onlyOwnerOrSuperuser {
    LuckyblockSpend memory _luckyblockSpend = LuckyblockSpend(
      spendTokenAddresses,
      spendTokenCount,
      spendEtherCount
    );
    luckyblockIdToLuckyblockSpend[luckyblockId] = _luckyblockSpend;
  }

  function updateLuckyblockEarn (
    bytes32 luckyblockId,
    address[] earnTokenAddresses,
    uint256[] earnTokenCount,
    int[] earnTokenProbability, // (0 - 100)
    uint256 earnEtherCount,
    int earnEtherProbability
    ) external onlyOwnerOrSuperuser {
    LuckyblockEarn memory _luckyblockEarn = LuckyblockEarn(
      earnTokenAddresses,
      earnTokenCount,
      earnTokenProbability, // (0 - 100)
      earnEtherCount,
      earnEtherProbability
    );
    luckyblockIdToLuckyblockEarn[luckyblockId] = _luckyblockEarn;
  }


  function play(bytes32 luckyblockId) external payable whenNotPaused {
    LuckyblockBase storage _luckyblockBase = luckyblockIdToLuckyblockBase[luckyblockId];
    LuckyblockSpend storage _luckyblockSpend = luckyblockIdToLuckyblockSpend[luckyblockId];
    LuckyblockEarn storage _luckyblockEarn = luckyblockIdToLuckyblockEarn[luckyblockId];
    
    require(!_luckyblockBase.ended, "luckyblock is ended");

    // check sender's ether balance 
    require(msg.value >= _luckyblockSpend.spendEtherCount, "sender value not enough");

    // check spend
    if (_luckyblockSpend.spendTokenAddresses[0] != address(0x0)) {
      for (uint8 i = 0; i < _luckyblockSpend.spendTokenAddresses.length; i++) {

        // check sender's erc20 balance 
        require(
          ERC20Interface(
            _luckyblockSpend.spendTokenAddresses[i]
          ).balanceOf(address(msg.sender)) >= _luckyblockSpend.spendTokenCount[i]
        );

        require(
          ERC20Interface(
            _luckyblockSpend.spendTokenAddresses[i]
          ).allowance(address(msg.sender), address(this)) >= _luckyblockSpend.spendTokenCount[i]
        );

        // transfer erc20 token
        ERC20Interface(_luckyblockSpend.spendTokenAddresses[i])
          .transferFrom(msg.sender, address(this), _luckyblockSpend.spendTokenCount[i]);
        }
    }
    
    // check earn erc20
    if (_luckyblockEarn.earnTokenAddresses[0] !=
      address(0x0)) {
      for (uint8 j= 0; j < _luckyblockEarn.earnTokenAddresses.length; j++) {
        // check sender's erc20 balance 
        uint256 earnTokenCount = _luckyblockEarn.earnTokenCount[j];
        require(
          ERC20Interface(_luckyblockEarn.earnTokenAddresses[j])
          .balanceOf(address(this)) >= earnTokenCount
        );
      }
    }
    
    // check earn ether
    require(address(this).balance >= _luckyblockEarn.earnEtherCount, "contract value not enough");

    // do a random
    uint8 _random = random();

    // earn erc20
    for (uint8 k = 0; k < _luckyblockEarn.earnTokenAddresses.length; k++){
      // if win erc20
      if (_luckyblockEarn.earnTokenAddresses[0]
        != address(0x0)){
        if (_random + _luckyblockEarn.earnTokenProbability[k] >= 100) {
          ERC20Interface(_luckyblockEarn.earnTokenAddresses[k])
            .transfer(msg.sender, _luckyblockEarn.earnTokenCount[k]);
        }
      }
    }
    uint256 value = msg.value;
    uint256 payExcess = value.sub(_luckyblockSpend.spendEtherCount);
    
    // if win ether
    if (_random + _luckyblockEarn.earnEtherProbability >= 100) {
      uint256 balance = _luckyblockEarn.earnEtherCount.add(payExcess);
      if (balance > 0){
        msg.sender.transfer(balance);
      }
    } else if (payExcess > 0) {
      msg.sender.transfer(payExcess);
    }
    
    emit Play(luckyblockId, msg.sender, _random);
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
 