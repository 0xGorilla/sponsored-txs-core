// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {ISignatureProxy} from 'interfaces/ISignatureProxy.sol';
import {ECDSA} from 'openzeppelin/utils/cryptography/ECDSA.sol';

// TODO: allow for batch txs
contract SignatureProxy is ISignatureProxy {
  using ECDSA for bytes32;

  uint256 public nonce;
  address public immutable owner;

  constructor(address _owner) {
    owner = _owner;
  }

  function exec(
    address _to,
    bytes memory _data,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external payable returns (bytes memory) {
    bytes32 _hash = keccak256(abi.encode(_to, _data, msg.value, block.chainid, nonce++));
    address _signer = ecrecover(_hash, _v, _r, _s);

    address _owner = owner;
    if (_owner != _signer) revert SignatureProxy_NotOwner(_owner, _signer);

    (bool _success, bytes memory _returnData) = address(_to).call{value: msg.value}(_data);
    if (!_success) revert SignatureProxy_FailedCall(_returnData);

    return _returnData;
  }
}
