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
import "../src/UserConfig.sol";

contract UserConfigTest is Test {
    UserConfig config;
    address immutable self = address(this);

    function setUp() public {
        config = new UserConfig(self);
    }

    function test_constructorArgs() public {
        assertEq(config.setter(), self);
        (address relayer, address oracle) = config.defaultUC();
        assertEq(relayer, address(0));
        assertEq(oracle, address(0));
    }

    function test_changeSetter() public {
        address s = address(0x1);
        config.changeSetter(s);
        assertEq(config.setter(), s);
    }

    function testFail_changeSetter() public {
        vm.prank(address(1));
        config.changeSetter(address(1));
    }

    function test_setDefaultConfig() public {
        config.setDefaultConfig(address(1), address(2));
        (address oracle, address relayer) = config.defaultUC();
        assertEq(oracle, address(1));
        assertEq(relayer, address(2));
    }

    function testFail_setDefaultConfig() public {
        vm.prank(address(1));
        config.setDefaultConfig(address(1), address(2));
    }

    function test_setAppConfig() public {
        UC memory c = config.getAppConfig(self);
        assertEq(c.oracle, address(0));
        assertEq(c.relayer, address(0));

        config.setAppConfig(address(1), address(2));
        c = config.getAppConfig(self);
        assertEq(c.oracle, address(1));
        assertEq(c.relayer, address(2));
    }

    function test_getAppConfig() public {
        UC memory c = config.getAppConfig(self);
        assertEq(c.relayer, address(0));
        assertEq(c.oracle, address(0));

        config.setDefaultConfig(address(1), address(2));
        c = config.getAppConfig(self);
        assertEq(c.oracle, address(1));
        assertEq(c.relayer, address(2));

        config.setAppConfig(address(3), address(4));
        c = config.getAppConfig(self);
        assertEq(c.oracle, address(3));
        assertEq(c.relayer, address(4));
    }
}
