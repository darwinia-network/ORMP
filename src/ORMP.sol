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

pragma solidity 0.8.17;

import "./Channel.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IRelayer.sol";
import "./security/ReentrancyGuard.sol";
import "./security/ExcessivelySafeCall.sol";

/// @title ORMP
/// @notice An endpoint is a type of network node for cross-chain communication.
/// It is an interface exposed by a communication channel.
/// @dev An endpoint is associated with an immutable channel and user configuration.
contract ORMP is ReentrancyGuard, Channel {
    using ExcessivelySafeCall for address;

    event MessageAssigned(
        bytes32 indexed msgHash, address indexed oracle, address indexed relayer, uint256 oracleFee, uint256 relayerFee
    );

    constructor(address dao) Channel(dao) {}

    function version() public pure returns (string memory) {
        return "2.0.0";
    }

    /// @dev Send a cross-chain message over the endpoint.
    /// @notice follow https://eips.ethereum.org/EIPS/eip-5750
    /// @param toChainId The Message destination chain id.
    /// @param to User application contract address which receive the message.
    /// @param gasLimit Gas limit for destination user application used.
    /// @param encoded The calldata which encoded by ABI Encoding.
    /// @param refund Return extra fee to refund address.
    function send(
        uint256 toChainId,
        address to,
        uint256 gasLimit,
        bytes calldata encoded,
        address refund,
        bytes calldata
    ) external payable sendNonReentrant returns (bytes32) {
        // user application address.
        address ua = msg.sender;
        // send message by channel, return the hash of the message as id.
        bytes32 msgHash = _send(ua, toChainId, to, gasLimit, encoded);

        // handle fee
        _handleFee(ua, refund, msgHash, toChainId, gasLimit, encoded);

        return msgHash;
    }

    function _handleFee(
        address ua,
        address refund,
        bytes32 msgHash,
        uint256 toChainId,
        uint256 gasLimit,
        bytes calldata encoded
    ) internal {
        // fetch user application's config.
        UC memory uc = getAppConfig(ua);
        // handle relayer fee
        uint256 relayerFee = _handleRelayer(uc.relayer, toChainId, ua, gasLimit, encoded);
        // handle oracle fee
        uint256 oracleFee = _handleOracle(uc.oracle, toChainId, ua);

        emit MessageAssigned(msgHash, uc.oracle, uc.relayer, oracleFee, relayerFee);

        // refund
        if (msg.value > relayerFee + oracleFee) {
            uint256 refundFee = msg.value - (relayerFee + oracleFee);
            _sendValue(refund, refundFee);
        }
    }

    /// @notice Get a quote in source native gas, for the amount that send() requires to pay for message delivery.
    /// @param toChainId The Message destination chain id.
    //  @param ua User application contract address which send the message.
    /// @param gasLimit Gas limit for destination user application used.
    /// @param encoded The calldata which encoded by ABI Encoding.
    function fee(uint256 toChainId, address ua, uint256 gasLimit, bytes calldata encoded, bytes calldata)
        external
        view
        returns (uint256)
    {
        UC memory uc = getAppConfig(ua);
        uint256 relayerFee = IRelayer(uc.relayer).fee(toChainId, ua, gasLimit, encoded);
        uint256 oracleFee = IOracle(uc.oracle).fee(toChainId, ua);
        return relayerFee + oracleFee;
    }

    function _handleRelayer(address relayer, uint256 toChainId, address ua, uint256 gasLimit, bytes calldata encoded)
        internal
        returns (uint256)
    {
        uint256 relayerFee = IRelayer(relayer).fee(toChainId, ua, gasLimit, encoded);
        _sendValue(relayer, relayerFee);
        return relayerFee;
    }

    function _handleOracle(address oracle, uint256 toChainId, address ua) internal returns (uint256) {
        uint256 oracleFee = IOracle(oracle).fee(toChainId, ua);
        _sendValue(oracle, oracleFee);
        return oracleFee;
    }

    /// @dev Recv verified message from Channel and dispatch to destination user application address.
    /// @notice Only channel could call this function.
    /// @param message Verified receive message info.
    /// @param proof Message proof of this message.
    /// @return dispatchResult Result of the message dispatch.
    function recv(Message calldata message, bytes calldata proof)
        external
        payable
        recvNonReentrant
        returns (bool dispatchResult)
    {
        bytes32 msgHash = _recv(message, proof);
        dispatchResult = _dispatch(message, msgHash);
        // emit dispatched message event.
        emit MessageDispatched(msgHash, dispatchResult);
    }

    /// @dev Dispatch the cross chain message.
    function _dispatch(Message memory message, bytes32 msgHash) private returns (bool dispatchResult) {
        // Deliver the message to user application contract address.
        (dispatchResult,) = message.to.excessivelySafeCall(
            message.gasLimit,
            msg.value,
            0,
            abi.encodePacked(message.encoded, msgHash, message.fromChainId, message.from)
        );
    }

    /// @dev Replacement for Solidity's `transfer`: sends `amount` wei to
    /// `recipient`, forwarding all available gas and reverting on errors.
    function _sendValue(address recipient, uint256 amount) internal {
        (bool success,) = recipient.call{value: amount}("");
        require(success, "!send");
    }
}
