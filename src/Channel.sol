// This file is part of Darwinia.
// Copyright (C) 2018-2022 Darwinia Network
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

pragma solidity 0.8.17;

import "./Common.sol";
import "./imt/IncrementalMerkleTree.sol";
import "./interfaces/IUserConfig.sol";
import "./interfaces/IVerifier.sol";

interface IEndpoint {
    function recv(Message calldata message) external returns (bool dispatch_result);
}

/// @title Channel
/// @notice Accepts messages to be dispatched to remote chains,
/// constructs a Merkle tree of the messages.
/// @dev TODO: doc
contract Channel {
    using IncrementalMerkleTree for IncrementalMerkleTree.Tree;
    /// @dev slot 0, messages root

    bytes32 private root;
    /// @dev incremental merkle tree
    IncrementalMerkleTree.Tree private imt;

    mapping(bytes32 => bool) public dones;

    address public immutable ENDPOINT;
    address public immutable CONFIG;

    event MessageAccepted(uint256 indexed index, bytes32 indexed msgHash, bytes32 root, Message message);
    event MessageDispatched(bytes32 indexed msgHash, bool dispatch_result);

    modifier onlyEndpoint() {
        require(msg.sender == ENDPOINT, "!endpoint");
        _;
    }

    constructor(address endpoint, address config) {
        // init with empty tree
        root = 0x27ae5ba08d7291c96c8cbddcc148bf48a6d68c7974b94356f53754ef6171d757;
        ENDPOINT = endpoint;
        CONFIG = config;
    }

    function LOCAL_CHAINID() public view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    /// @dev Send message
    function sendMessage(address from, uint256 toChainId, address to, bytes calldata encoded)
        external
        onlyEndpoint
        returns (uint256)
    {
        uint256 index = messageSize();
        Message memory message = Message({
            index: index,
            fromChainId: LOCAL_CHAINID(),
            from: from,
            toChainId: toChainId,
            to: to,
            encoded: encoded
        });
        bytes32 msgHash = hash(message);
        imt.insert(msgHash);
        root = imt.root();

        emit MessageAccepted(index, msgHash, root, message);

        return index;
    }

    /// Receive messages proof from bridged chain.
    function recvMessage(Message calldata message, bytes calldata proof) external {
        Config memory uaConfig = IUserConfig(CONFIG).getAppConfig(message.to);
        require(uaConfig.relayer == msg.sender);

        // verify message is from the correct source chain
        IVerifier(uaConfig.oracle).verifyMessageProof(message.fromChainId, hash(message), proof);

        require(LOCAL_CHAINID() == message.toChainId, "InvalidTargetLaneId");
        bytes32 msgHash = hash(message);
        require(dones[msgHash] == false, "done");
        dones[msgHash] = true;

        // then, dispatch message
        bool dispatchResult = IEndpoint(ENDPOINT).recv(message);
        emit MessageDispatched(msgHash, dispatchResult);
    }

    /// Return the commitment of lane data.
    function commitment() external view returns (bytes32) {
        return root;
    }

    function messageSize() public view returns (uint256) {
        return imt.count;
    }

    function imtBranch() public view returns (bytes32[32] memory) {
        return imt.branch;
    }
}
