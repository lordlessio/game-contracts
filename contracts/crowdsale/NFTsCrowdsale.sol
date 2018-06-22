pragma solidity ^0.4.23;

import "../../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./EthDefaryPausable.sol";
import "./NFTsCrowdsaleBase.sol";


contract NFTsCrowdsale is NFTsCrowdsaleBase, EthDefaryPausable, Pausable{

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
   * @dev defray a auction by eth
   * @param _tokenId ldb tokenid
   */
  function defrayByEth (uint256 _tokenId) whenNotEthPaused external payable {
    _defrayByEth(_tokenId); 
  }

  /**
   * @dev defray a auction by erc20 Token
   * @param _tokenId ldb tokenid
   */
  function defrayByErc20 (uint256 _tokenId) whenNotPaused external {
    _defrayByErc20(_tokenId);
  }

  /**
   * @dev cancel a auction
   * @param _tokenId ldb tokenid
   */
  function cancelAuction (uint256 _tokenId) external {
    _cancelAuction(_tokenId);
  }

  /**
   * @dev get a auction detail by _tokenId
   * @param _tokenId ldb tokenid
   */
}
