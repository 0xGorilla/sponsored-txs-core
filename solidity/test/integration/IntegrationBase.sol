// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import 'forge-std/Test.sol';

contract IntegrationBase is Test {
  uint256 internal constant _FORK_BLOCK = 10_115_368;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('goerli'), _FORK_BLOCK);
  }
}
