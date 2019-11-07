pragma solidity ^0.5.0;

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

import "../reputation/ReputationI.sol";

interface ConsensusI {
    /**
     * @notice Get the reputation contract address.
     * returns Reputation contract address.
     */
    function reputation()
        external
        view
        returns (ReputationI reputation_);

    /** Get minimum validator and join limit count. */
    function coreValidatorThresholds()
        external
        view
        returns (uint256 minimumValidatorCount_, uint256 joinLimit_);

    /**
     * @notice Register a proposal for commit.
     * @param _proposal Precommit proposal.
     */
    function registerPrecommit(
        bytes32 _proposal
    )
        external;

    /**
     * @notice Create a new meta chain.
     * @param _chainId Chain id for new meta-chain.
     * @param _epochLength Epoch length for new meta-chain.
     * @param _source Source block hash.
     * @param _sourceBlockHeight Source block height.
     */
    function newMetaChain(
        bytes20 _chainId,
        uint256 _epochLength,
        bytes32 _source,
        uint256 _sourceBlockHeight
    )
        external;
}
