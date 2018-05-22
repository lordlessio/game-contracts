contract LdbAccessControl {
    
  address public ceo;
  address public coo;
  address public cfo;



  /// @dev Access modifier for CEO-only functionality
  modifier onlyCEO() {
    require(msg.sender == ceo);
    _;
  }

  /// @dev Access modifier for CFO-only functionality
  modifier onlyCFO() {
    require(msg.sender == cfo);
    _;
  }

  /// @dev Access modifier for COO-only functionality
  modifier onlyCOO() {
    require(msg.sender == coo);
    _;
  }

  modifier onlyCLevel() {
    require(
      msg.sender == coo ||
      msg.sender == ceo ||
      msg.sender == cfo
    );
    _;
  }

  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
  /// @param _newCEO The address of the new CEO
  function setCEO(address _newCEO) external onlyCEO {
    require(_newCEO != address(0));

    ceo = _newCEO;
  }

  /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
  /// @param _newCFO The address of the new CFO
  function setCFO(address _newCFO) external onlyCEO {
    require(_newCFO != address(0));

    cfo = _newCFO;
  }

  /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
  /// @param _newCOO The address of the new COO
  function setCOO(address _newCOO) external onlyCEO {
    require(_newCOO != address(0));

    coo = _newCOO;
  }
}

