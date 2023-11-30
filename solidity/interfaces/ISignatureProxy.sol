// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

interface ISignatureProxy {
  error SignatureProxy_NotOwner(address _owner, address _signer);
  error SignatureProxy_FailedCall(bytes _returnData);

  function OWNER() external returns (address _owner);
  function nonce() external returns (uint256 _nonce);
  function exec(
    address _to,
    bytes memory _data,
    uint256 _value,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external payable returns (bytes memory _returnData);
}
