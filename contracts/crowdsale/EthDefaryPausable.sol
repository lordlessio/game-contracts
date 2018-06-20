pragma solidity ^0.4.23;


import "../../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract EthDefaryPausable is Ownable {
  event EthPause();
  event UnEthPause();

  bool public ethPaused = false;
  
  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotEthPaused() {
    require(!ethPaused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenEthPaused() {
    require(ethPaused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function ethPause() onlyOwner whenNotEthPaused public {
    ethPaused = true;
    emit EthPause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function ethUnPause() onlyOwner whenEthPaused public {
    ethPaused = false;
    emit UnEthPause();
  }
}
