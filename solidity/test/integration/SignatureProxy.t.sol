// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';
import {SignatureProxyFactory} from 'contracts/SignatureProxyFactory.sol';
import {ISignatureProxyFactory} from 'interfaces/ISignatureProxyFactory.sol';
import {ISignatureProxy} from 'interfaces/ISignatureProxy.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

interface ITestToken is IERC20 {
  function mint(uint256 _amount) external;
}

contract IntegrationSignatureProxy is IntegrationBase {
  IERC20 public testToken = IERC20(0x16F63C5036d3F48A239358656a8f123eCE85789C);
  address public signer;
  uint256 public signerPk;
  ISignatureProxyFactory public proxyFactory;
  ISignatureProxy public signerProxy;

  function setUp() public override {
    super.setUp();

    // create a new empty wallet
    (signer, signerPk) = makeAddrAndKey('alice');

    // deploy a gasless proxy
    proxyFactory = new SignatureProxyFactory();
    signerProxy = proxyFactory.deploy(signer);
  }

  function test_deterministic_address() public {
    ISignatureProxy _expectedProxy = proxyFactory.getSignatureProxy(signer);
    assertEq(address(signerProxy), address(_expectedProxy));
  }

  function test_gasless_tx(uint128 _amount) public {
    // sign a mint tx from our signer
    bytes memory _data = abi.encodeCall(ITestToken.mint, _amount);
    bytes32 _hash = keccak256(abi.encode(testToken, _data, 0, block.chainid, signerProxy.nonce()));
    (uint8 _v, bytes32 _r, bytes32 _s) = vm.sign(signerPk, _hash);

    // execute the tx as a sponsor
    signerProxy.exec(address(testToken), _data, _v, _r, _s);

    // verify that the tx went through and that the assets were minted
    assertEq(testToken.balanceOf(address(signerProxy)), _amount);
  }

  function test_incorrect_signature(uint128 _amount) public {
    (address _incorrectSigner, uint256 _incorrectSignerPk) = makeAddrAndKey('bob');

    // sign a mint transaction from an incorrect signer
    bytes memory _data = abi.encodeCall(ITestToken.mint, _amount);
    bytes32 _hash = keccak256(abi.encode(testToken, _data, 0, block.chainid, signerProxy.nonce()));
    (uint8 _v, bytes32 _r, bytes32 _s) = vm.sign(_incorrectSignerPk, _hash);

    // expect the proxy to revert
    vm.expectRevert(abi.encodeWithSelector(ISignatureProxy.SignatureProxy_NotOwner.selector, signer, _incorrectSigner));
    signerProxy.exec(address(testToken), _data, _v, _r, _s);
  }
}
