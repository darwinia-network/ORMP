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

import "../Verifier.sol";
import "../interfaces/IFeedOracle.sol";

contract OracleV2 is Verifier {
    event Assigned(bytes32 indexed msgHash, uint256 fee);
    event SetFee(uint256 indexed chainId, uint256 fee);
    event SetApproved(address operator, bool approve);
    event ImporedMessageRoot(uint256 indexed chaindId, uint256 indexed blockNumber, bytes32 messageRoot);

    address public immutable PROTOCOL;

    address public owner;
    // chainId => price
    mapping(uint256 => uint256) public feeOf;
    // chainId => blockNumber => messageRoot
    mapping(uint256 => mapping(uint256 => bytes32)) rootOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor(address dao, address ormp) {
        PROTOCOL = ormp;
        owner = dao;
    }

    receive() external payable {}

    function importMessageRoot(uint256 chainId, uint256 blockNumber, bytes32 messageRoot) external onlyOwner {
        rootOf[chainId][blockNumber] = messageRoot;
        emit ImporedMessageRoot(chainId, blockNumber, messageRoot);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        (bool success,) = to.call{value: amount}("");
        require(success, "!withdraw");
    }

    function changeOwner(address owner_) external onlyOwner {
        owner = owner_;
    }

    function setFee(uint256 chainId, uint256 fee_) external onlyOwner {
        feeOf[chainId] = fee_;
        emit SetFee(chainId, fee_);
    }

    function fee(uint256 toChainId, address /*ua*/ ) public view returns (uint256) {
        return feeOf[toChainId];
    }

    function assign(bytes32 msgHash) external payable {
        require(msg.sender == PROTOCOL, "!auth");
        emit Assigned(msgHash, msg.value);
    }

    function merkleRoot(uint256 chainId, uint256 blockNumber) public view override returns (bytes32) {
        return rootOf[chaindId][blockNumber];
    }
}
