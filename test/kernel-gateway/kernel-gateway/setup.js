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

const { AccountProvider } = require('../../test_lib/utils.js');
const Utils = require('../../test_lib/utils.js');
const KernelUtils = require('../utils');

const KernelGateway = artifacts.require('KernelGateway');

contract('KernelGateway::setup', (accounts) => {
  const accountProvider = new AccountProvider(accounts);
  let kernelGateway;
  let setupParams = {};

  beforeEach(async () => {
    kernelGateway = await KernelGateway.new();
    setupParams = {
      chainId: accountProvider.get(),
      kernelCoGateway: accountProvider.get(),
      txOptions: {
        from: accountProvider.get(),
      },
    };
  });

  contract('Negative Tests', () => {
    it('should fail when chain id is 0', async () => {
      setupParams.chainId = Utils.NULL_ADDRESS;
      await Utils.expectRevert(
        KernelUtils.setupKernelGateway(kernelGateway, setupParams),
        'Chain id is 0.',
      );
    });

    it('should fail when kernel cogateway address is 0', async () => {
      setupParams.kernelCoGateway = Utils.NULL_ADDRESS;
      await Utils.expectRevert(
        KernelUtils.setupKernelGateway(kernelGateway, setupParams),
        'KernelCoGateway address is 0.',
      );
    });

    it('should fail when contract is already setup once', async () => {
      await KernelUtils.setupKernelGateway(kernelGateway, setupParams);
      await Utils.expectRevert(
        KernelUtils.setupKernelGateway(kernelGateway, setupParams),
        'Kernel gateway is already setup.',
      );
    });
  });

  contract('Positive Tests', () => {
    it('should pass when called with correct parameters', async () => {
      await KernelUtils.setupKernelGateway(kernelGateway, setupParams);
    });

    it('chainId should be set in the contract', async () => {
      await KernelUtils.setupKernelGateway(kernelGateway, setupParams);
      const chainId = await kernelGateway.chainId.call();
      assert.strictEqual(
        Utils.toChecksumAddress(chainId),
        setupParams.chainId,
        'Chain id is not set in the contract.',
      );
    });

    it('consensus contract address should be set in the contract', async () => {
      await KernelUtils.setupKernelGateway(kernelGateway, setupParams);
      const consensus = await kernelGateway.consensus.call();
      assert.strictEqual(
        consensus,
        setupParams.txOptions.from,
        'Consensus address is not set in the contract.',
      );
    });
  });
});
