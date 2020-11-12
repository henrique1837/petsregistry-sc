pragma solidity ^0.6.6;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Controller is AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("minter");
  modifier onlyMinter {
      require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
              "Sender is not minter");
      _;
  }
}
