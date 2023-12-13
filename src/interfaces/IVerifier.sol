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

interface IVerifier {
    /// @notice Fetch message root oracle.
    /// @param chainId The destination chain id.
    /// @param blockNumber The block number where the message root is located.
    /// @return Message root in destination chain.
    function merkleRoot(uint256 chainId, uint256 blockNumber) external view returns (bytes32);

    /// @notice Verify message proof
    /// @dev Message proof provided by relayer. Oracle should provide message root of
    ///      source chain, and verify the merkle proof of the message hash.
    /// @param fromChainId Source chain id.
    /// @param msgHash Hash of the message.
    /// @param proof Merkle proof of the message
    /// @return Result of the message verify.
    function verifyMessageProof(uint256 fromChainId, bytes32 msgHash, bytes calldata proof)
        external
        view
        returns (bool);
}
