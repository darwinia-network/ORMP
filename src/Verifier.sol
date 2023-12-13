// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.20;

import "./interfaces/IVerifier.sol";
import "./imt/IncrementalMerkleTree.sol";

abstract contract Verifier is IVerifier {
    /// @notice Message proof.
    /// @param blockNumber The block number corresponding to the proof.
    /// @param messageIndex Leaf index of the message hash in incremental merkle tree.
    /// @param messageProof Merkle proof of the message hash.
    struct Proof {
        uint256 blockNumber;
        uint256 messageIndex;
        bytes32[32] messageProof;
    }

    /// @inheritdoc IVerifier
    function merkleRoot(uint256 chainId, uint256 blockNumber) public view virtual returns (bytes32);

    /// @inheritdoc IVerifier
    function verifyMessageProof(uint256 fromChainId, bytes32 msgHash, bytes calldata proof)
        external
        view
        returns (bool)
    {
        // decode proof
        Proof memory p = abi.decode(proof, (Proof));

        // fetch message root in block number from chain
        bytes32 imtRootOracle = merkleRoot(fromChainId, p.blockNumber);
        // calculate the expected root based on the proof
        bytes32 imtRootProof = IncrementalMerkleTree.branchRoot(msgHash, p.messageProof, p.messageIndex);

        // check oracle's merkle root equal relayer's merkle root
        return imtRootOracle == imtRootProof;
    }
}
