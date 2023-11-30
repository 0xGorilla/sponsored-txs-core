// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {ISignatureProxyFactory} from '../interfaces/ISignatureProxyFactory.sol';
import {ISignatureProxy} from '../interfaces/ISignatureProxy.sol';
import {SignatureProxy} from './SignatureProxy.sol';

contract SignatureProxyFactory is ISignatureProxyFactory {
  function deploy(address _owner) external returns (ISignatureProxy _signatureProxy) {
    return _deploy(_owner);
  }

  function deployAndExec(
    address _owner,
    address _to,
    bytes memory _data,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external payable returns (ISignatureProxy _signatureProxy, bytes memory _returnData) {
    _signatureProxy = _deploy(_owner);
    _returnData = _signatureProxy.exec(_to, _data, _v, _r, _s);
  }

  function getSignatureProxy(address _owner) external view returns (ISignatureProxy _signatureProxy) {
    _signatureProxy = ISignatureProxy(
      address(
        uint160(
          uint256(
            keccak256(
              abi.encodePacked(
                bytes1(0xff), // prefix
                address(this), // deployer
                keccak256(abi.encode(_owner)), // salt
                keccak256(abi.encodePacked(type(SignatureProxy).creationCode, abi.encode(_owner)))
              )
            )
          )
        )
      )
    );
  }

  function _deploy(address _owner) internal returns (ISignatureProxy _signatureProxy) {
    _signatureProxy = new SignatureProxy{salt: keccak256(abi.encode(_owner))}(_owner);
    emit DeploySignatureProxy(_owner, _signatureProxy);
  }
}
