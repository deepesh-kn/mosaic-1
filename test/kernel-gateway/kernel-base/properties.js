// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

const BN = require('bn.js');

const { AccountProvider } = require('../../test_lib/utils.js');
const Utils = require('../../test_lib/utils.js');
const KernelUtils = require('../utils');

const KernelBaseTest = artifacts.require('KernelBaseTest');

contract('KernelBase::properties', (accounts) => {
  const accountProvider = new AccountProvider(accounts);

  let kernelBase;
  beforeEach(async () => {
    kernelBase = await KernelBaseTest.new();
  });

  contract('Properties', () => {
    it('should return correct value for KERNEL_TYPEHASH', async () => {
      const expectedTypeHash = KernelUtils.KERNEL_TYPEHASH;
      const kernelTypeHash = await kernelBase.KERNEL_TYPEHASH.call();

      assert.strictEqual(
        kernelTypeHash,
        expectedTypeHash,
        'Kernel type hash should match with the expected hash.',
      );
    });

    it('Variable chainId should exist in contract', async () => {

      const expectedChainId = accountProvider.get();
      await kernelBase.setChainId(expectedChainId);
      const chainId = await kernelBase.chainId.call();
      assert.strictEqual(
        Utils.toChecksumAddress(chainId),
        expectedChainId,
        'Chain id value is not set.',
      );
    });

    it('Variable nonce should exist in contract', async () => {
      const expectedNonce = Utils.getRandomNumber(99999);
      await kernelBase.setNonce(new BN(expectedNonce));
      const nonce = await kernelBase.nonce.call();

      assert.strictEqual(
        nonce.eqn(expectedNonce),
        true,
        'Nonce value is not set.',
      );
    });

    it('Variable latestKernelHeight should exist in contract', async () => {
      const expectedKernelHeight = Utils.getRandomNumber(99999);
      await kernelBase.setLatestKernelHeight(new BN(expectedKernelHeight));
      const latestKernelHeight = await kernelBase.latestKernelHeight.call();

      assert.strictEqual(
        latestKernelHeight.eqn(expectedKernelHeight),
        true,
        'Latest kernel height value is not set.',
      );
    });

    it('Variable latestGasTarget should exist in contract', async () => {
      const expectedLatestGasTarget = Utils.getRandomNumber(99999);
      await kernelBase.setLatestGasTarget(new BN(expectedLatestGasTarget));
      const latestGasTarget = await kernelBase.latestGasTarget.call();

      assert.strictEqual(
        latestGasTarget.eqn(expectedLatestGasTarget),
        true,
        'Latest gas target value is not set.',
      );
    });

    it('Variable kernelMessages should exist in contract', async () => {
      const key = Utils.getRandomHash();
      const expectedValue = Utils.getRandomHash();
      await kernelBase.setKernelMessage(key, expectedValue);
      const value = await kernelBase.kernelMessages.call(key);

      assert.strictEqual(
        value,
        expectedValue,
        'Kernel message is not set in the contract.',
      );
    });
  });
});
