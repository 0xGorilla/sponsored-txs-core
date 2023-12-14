// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Script} from 'forge-std/Script.sol';
import {SignatureProxyFactory} from 'contracts/SignatureProxyFactory.sol';

contract Deploy is Script {
  function run() external {
    vm.startBroadcast();
    SignatureProxyFactory factory = new SignatureProxyFactory();
    factory.deploy(msg.sender);
    vm.stopBroadcast();
  }
}
