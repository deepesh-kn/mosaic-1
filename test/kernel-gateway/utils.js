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

const Utils = require('../test_lib/utils.js');

const KERNEL_TYPEHASH_STRING = 'Kernel(uint256 height,bytes32 parent,address[] updatedValidators,uint256[] updatedReputation,uint256 gasTarget)';
const KERNEL_TYPEHASH = Utils.hash(KERNEL_TYPEHASH_STRING);

async function setupKernelGateway(kernelGateway, setupParams) {
  await kernelGateway.setup(
    setupParams.chainId,
    setupParams.kernelCoGateway,
    setupParams.txOptions,
  );
}
module.exports = {
  KERNEL_TYPEHASH,
  setupKernelGateway,
};
