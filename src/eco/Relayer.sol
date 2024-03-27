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

import "../interfaces/IORMP.sol";

contract Relayer {
    event SetDstPrice(uint256 indexed chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei);
    event SetDstConfig(uint256 indexed chainId, uint64 baseGas, uint64 gasPerByte);
    event SetApproved(address operator, bool approve);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct DstPrice {
        uint128 dstPriceRatio; // dstPrice / localPrice * 10^10
        uint128 dstGasPriceInWei;
    }

    struct DstConfig {
        uint64 baseGas;
        uint64 gasPerByte;
    }

    address public immutable PROTOCOL;

    address public owner;
    // chainId => price
    mapping(uint256 => DstPrice) public priceOf;
    mapping(uint256 => DstConfig) public configOf;
    mapping(address => bool) public approvedOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    modifier onlyApproved() {
        require(isApproved(msg.sender), "!approve");
        _;
    }

    constructor(address dao, address ormp) {
        PROTOCOL = ormp;
        owner = dao;
    }

    function version() public pure returns (string memory) {
        return "2.0.0";
    }

    receive() external payable {}

    function withdraw(address to, uint256 amount) external onlyApproved {
        (bool success,) = to.call{value: amount}("");
        require(success, "!withdraw");
    }

    function isApproved(address operator) public view returns (bool) {
        return approvedOf[operator];
    }

    function changeOwner(address newOwner) external onlyOwner {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setApproved(address operator, bool approve) public onlyOwner {
        approvedOf[operator] = approve;
        emit SetApproved(operator, approve);
    }

    function setDstPrice(uint256 chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei) external onlyApproved {
        priceOf[chainId] = DstPrice(dstPriceRatio, dstGasPriceInWei);
        emit SetDstPrice(chainId, dstPriceRatio, dstGasPriceInWei);
    }

    function setDstConfig(uint256 chainId, uint64 baseGas, uint64 gasPerByte) external onlyApproved {
        configOf[chainId] = DstConfig(baseGas, gasPerByte);
        emit SetDstConfig(chainId, baseGas, gasPerByte);
    }

    // extraGas = gasLimit
    function fee(uint256 toChainId, address, /*ua*/ uint256 gasLimit, bytes calldata encoded)
        public
        view
        returns (uint256)
    {
        uint256 size = encoded.length;
        uint256 extraGas = gasLimit;
        DstPrice memory p = priceOf[toChainId];
        DstConfig memory c = configOf[toChainId];

        require(c.baseGas != 0, "!baseGas");
        // remoteToken = dstGasPriceInWei * (baseGas + extraGas)
        uint256 remoteToken = p.dstGasPriceInWei * (c.baseGas + extraGas);
        // dstPriceRatio = dstPrice / localPrice * 10^10
        // sourceToken = RemoteToken * dstPriceRatio
        uint256 sourceToken = remoteToken * p.dstPriceRatio / (10 ** 10);
        uint256 payloadToken = c.gasPerByte * size * p.dstGasPriceInWei * p.dstPriceRatio / (10 ** 10);
        return sourceToken + payloadToken;
    }

    function relay(Message calldata message, bytes calldata proof) external onlyApproved {
        IORMP(PROTOCOL).recv(message, proof);
    }
}
