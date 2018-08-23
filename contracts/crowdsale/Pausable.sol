pragma solidity ^0.4.24;


import "../../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  event Pause2();
  event Unpause2();

  bool public paused = false;
  bool public paused2 = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenNotPaused2() {
    require(!paused2);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  modifier whenPaused2() {
    require(paused2);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  function pause2() public onlyOwner whenNotPaused2 {
    paused2 = true;
    emit Pause2();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }

  function unpause2() public onlyOwner whenPaused2 {
    paused2 = false;
    emit Unpause2();
  }
}
