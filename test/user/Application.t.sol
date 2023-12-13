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

import "forge-std/Test.sol";
import "../../src/user/Application.sol";
import "../../src/security/ExcessivelySafeCall.sol";

contract ApplicationTest is Test {
    using ExcessivelySafeCall for address;

    UserApplication ua;
    address immutable self = address(this);

    function setUp() public {
        ua = new UserApplication(self);
    }

    function test_recv() public {
        (bool dispatchResult,) = address(ua).excessivelySafeCall(
            gasleft(), 0, 0, abi.encodePacked(ua.recv.selector, bytes32(uint256(1)), uint256(1), self)
        );
        assertEq(dispatchResult, true);
    }

    function testFail_recv() public {
        (bool dispatchResult,) = address(ua).excessivelySafeCall(
            gasleft(), 0, 0, abi.encodePacked(ua.recv.selector, bytes32(uint256(1)), uint256(1), address(1))
        );
        assertEq(dispatchResult, true);
    }
}

contract UserApplication is Application {
    constructor(address ormp) Application(ormp) {}

    function setAppConfig(address relayer, address oracle) public {}

    function recv() public view {
        bytes32 msgHash = _messageId();
        uint256 fromChainid = _fromChainId();
        address xmsgSender = _xmsgSender();
        require(msgHash == bytes32(uint256(1)));
        require(fromChainid == 1);
        require(xmsgSender == TRUSTED_ORMP);
    }
}
