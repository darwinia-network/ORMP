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
import "../../src/eco/Relayer.sol";

contract RelayerTest is Test {
    Relayer relayer;
    address immutable self = address(this);

    receive() external payable {}

    function setUp() public {
        relayer = new Relayer(self, self);
        relayer.setApproved(self, true);
    }

    function test_constructorArgs() public {
        assertEq(relayer.PROTOCOL(), self);
        assertEq(relayer.owner(), self);
    }

    function test_changeOwner() public {
        address s = address(0x1);
        relayer.changeOwner(s);
        assertEq(relayer.owner(), s);
    }

    function testFail_changeOwner() public {
        vm.prank(address(1));
        relayer.changeOwner(address(1));
    }

    function test_withdraw() public {
        vm.deal(address(relayer), 1);
        relayer.withdraw(self, 1);

        vm.deal(address(relayer), 1);
        address a = address(1);
        relayer.setApproved(a, true);
        vm.prank(a);
        relayer.withdraw(a, 1);
    }

    function testFail_withdraw() public {
        relayer.withdraw(self, 1);
    }

    function test_setApproved() public {
        address a = address(1);
        relayer.setApproved(a, true);
        bool approved = relayer.isApproved(a);
        assertEq(approved, true);
    }

    function testFail_setApproved() public {
        address a = address(1);
        vm.prank(a);
        relayer.setApproved(a, true);
    }

    function test_setPrice() public {
        relayer.setDstPrice(1, 10 ** 10, 1);
        relayer.setDstConfig(1, 1, 1);
        uint256 f = relayer.fee(1, self, 1, hex"00", abi.encode(uint256(1)));
        assertEq(f, 3);
    }

    function test_assign() public {
        relayer.setDstPrice(1, 10 ** 10, 1);
        relayer.setDstConfig(1, 1, 1);
        uint256 v = relayer.fee(1, address(1), 1, hex"00", abi.encode(uint256(1)));
        relayer.assign{value: v}(bytes32(0), abi.encode(uint256(1)));
        assertEq(v, 3);
    }

    function test_relay() public {
        Message memory message = Message({
            channel: address(0xc),
            index: 0,
            fromChainId: 1,
            from: self,
            toChainId: 2,
            to: self,
            gasLimit: 0,
            encoded: ""
        });
        relayer.relay(message, "");
    }

    function recv(Message calldata message, bytes calldata proof) external returns (bool) {}
    function prove() external returns (bytes32[32] memory) {}
}
