pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./EthPayPausable.sol";
import "./NFTsCrowdsaleBase.sol";


contract NFTsCrowdsale is NFTsCrowdsaleBase, EthPayPausable, Pausable{

  constructor(address _erc721Address, address _erc20Address, uint _eth2erc20) public 
  NFTsCrowdsaleBase(_erc721Address, _erc20Address, _eth2erc20){}

  function () external payable {}

  function withdrawBalance() onlyOwnerOrSuperuser external {
    owner.transfer(address(this).balance);
  }

  function newAuction(uint128 _price, uint256 _tokenId, uint256 _endAt) whenNotPaused external {
    _newAuction(_price, _tokenId, _endAt);
  }

  /**
   * @dev pay a auction by eth
   * @param _tokenId ldb tokenid
   */
  function payByEth (uint256 _tokenId) whenNotEthPaused external payable {
    _payByEth(_tokenId); 
  }

  /**
   * @dev pay a auction by erc20 Token
   * @param _tokenId ldb tokenid
   */
  function payByErc20 (uint256 _tokenId) whenNotPaused external {
    _payByErc20(_tokenId);
  }

  /**
   * @dev cancel a auction
   * @param _tokenId ldb tokenid
   */
  function cancelAuction (uint256 _tokenId) external {
    _cancelAuction(_tokenId);
  }
}
