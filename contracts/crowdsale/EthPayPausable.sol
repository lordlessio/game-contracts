pragma solidity ^0.4.23;


import "../../node_modules/zeppelin-solidity/contracts/ownership/Superuser.sol";


/**
 * @title EthPayPausable Pausable
 */
contract EthPayPausable is Superuser {
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
  function ethPause() onlyOwnerOrSuperuser whenNotEthPaused public {
    ethPaused = true;
    emit EthPause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function ethUnPause() onlyOwnerOrSuperuser whenEthPaused public {
    ethPaused = false;
    emit UnEthPause();
  }
}
