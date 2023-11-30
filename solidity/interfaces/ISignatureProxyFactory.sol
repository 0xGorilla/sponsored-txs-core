// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import './ISignatureProxy.sol';

interface ISignatureProxyFactory {
  event DeploySignatureProxy(address _owner, ISignatureProxy _signatureProxy);

  function deploy(address _owner) external returns (ISignatureProxy _signatureProxy);

  function deployAndExec(
    address _owner,
    address _to,
    bytes memory _data,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external payable returns (ISignatureProxy _signatureProxy, bytes memory _returnData);

  function getSignatureProxy(address _owner) external view returns (ISignatureProxy _signatureProxy);
}
