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

import "./UserConfig.sol";
import "./interfaces/IVerifier.sol";
import "./imt/IncrementalMerkleTree.sol";

/// @title Channel
/// @notice A channel is a logical connection over cross-chain network.
/// It used for cross-chain message transfer.
/// - Accepts messages to be dispatched to destination chains,
///   constructs a Merkle tree of the messages.
/// - Dispatches verified messages from source chains.
/// @dev Messages live in an incremental merkle tree (imt)
/// > A Merkle tree is a binary and complete tree decorated with
/// > the Merkle (hash) attribute.
contract Channel is UserConfig {
    using IncrementalMerkleTree for IncrementalMerkleTree.Tree;

    /// @dev Incremental merkle tree root which all message hashes live in leafs.
    bytes32 public root;
    /// @dev Incremental merkle tree.
    IncrementalMerkleTree.Tree private _imt;
    /// @dev msgHash => isDispathed.
    mapping(bytes32 => bool) public dones;

    /// @dev Self contract address cache.
    address private immutable __self = address(this);

    /// @dev Notifies an observer that the message has been accepted.
    /// @param msgHash Hash of the message.
    /// @param root New incremental merkle tree root after a new message inserted.
    /// @param message Accepted message info.
    event MessageAccepted(bytes32 indexed msgHash, bytes32 root, Message message);
    /// @dev Notifies an observer that the message has been dispatched.
    /// @param msgHash Hash of the message.
    /// @param dispatchResult The message dispatch result.
    event MessageDispatched(bytes32 indexed msgHash, bool dispatchResult);

    /// @dev Init code.
    constructor(address dao) UserConfig(dao) {
        // init with empty tree
        root = 0x27ae5ba08d7291c96c8cbddcc148bf48a6d68c7974b94356f53754ef6171d757;
    }

    /// @dev Fetch local chain id.
    /// @return chainId Local chain id.
    function LOCAL_CHAINID() public view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    /// @dev Send message.
    /// @param from User application contract address which send the message.
    /// @param toChainId The Message destination chain id.
    /// @param to User application contract address which receive the message.
    /// @param gasLimit Gas limit for destination user application used.
    /// @param encoded The calldata which encoded by ABI Encoding.
    function _send(address from, uint256 toChainId, address to, uint256 gasLimit, bytes calldata encoded)
        internal
        returns (bytes32)
    {
        // only cross-chain message
        require(toChainId != LOCAL_CHAINID(), "!cross-chain");
        // get this message leaf index.
        uint256 index = messageCount();
        // constuct message object.
        Message memory message = Message({
            channel: __self,
            index: index,
            fromChainId: LOCAL_CHAINID(),
            from: from,
            toChainId: toChainId,
            to: to,
            gasLimit: gasLimit,
            encoded: encoded
        });
        // hash the message.
        bytes32 msgHash = hash(message);
        // insert msg hash to imt.
        _imt.insert(msgHash);
        // update new imt.root to root storage.
        root = _imt.root();

        // emit accepted message event.
        emit MessageAccepted(msgHash, root, message);

        // return this message hash.
        return msgHash;
    }

    /// @dev Receive messages.
    /// @notice Only message.to's config relayer could relay this message.
    /// @param message Received message info.
    /// @param proof Message proof of this message.
    function _recv(Message calldata message, bytes calldata proof) internal returns (bytes32) {
        // get message.to user config.
        UC memory uc = getAppConfig(message.to);
        // only the config relayer could relay this message.
        require(uc.relayer == msg.sender, "!auth");

        // hash the message.
        bytes32 msgHash = hash(message);
        // verify message by the config oracle.
        require(IVerifier(uc.oracle).verifyMessageProof(message.fromChainId, msgHash, proof), "!proof");

        // check destination chain id is correct.
        require(LOCAL_CHAINID() == message.toChainId, "!toChainId");
        // check the message is not dispatched.
        require(dones[msgHash] == false, "done");
        // set the message is dispatched.
        dones[msgHash] = true;

        return msgHash;
    }

    /// @dev Fetch the messages count of incremental merkle tree.
    function messageCount() public view returns (uint256) {
        return _imt.count;
    }

    /// @dev Fetch the branch of incremental merkle tree.
    function imtBranch() public view returns (bytes32[32] memory) {
        return _imt.branch;
    }

    /// @dev Fetch the latest message proof
    function prove() public view returns (bytes32[32] memory) {
        return _imt.prove();
    }
}
