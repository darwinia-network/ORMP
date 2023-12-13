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
import "../src/Common.sol";

contract CommonTest is Test {
    function test_hashMessage() public {
        Message memory message = Message({
            channel: address(0xc),
            index: 0,
            fromChainId: 1,
            from: address(0x0),
            toChainId: 2,
            to: address(0x0),
            gasLimit: 0,
            encoded: ""
        });
        assertEq0(
            hex"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000",
            abi.encode(message)
        );
        assertEq(bytes32(0x71fb3c3f4e014e5f86a232c7c14dc843164c056fd16a026cfea4fe4f814236e7), hash(message));
    }

    function test_hashMessage_real() public {
        Message memory message = Message({
            channel: 0x00000000fec9f746a2138D9C6f42794236f3aca8,
            index: 1,
            fromChainId: 421613,
            from: 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec,
            toChainId: 43,
            to: 0x000000fbfBc6954C8CBba3130b5Aee7f3Ea5108e,
            gasLimit: 0,
            encoded: ""
        });
        assertEq(bytes32(0x16ef90052810b57bc4e8e2af6c78a9160259b8b754fe2b2cb943adeb716dd024), hash(message));
    }

    function test_hashMessage_debug() public {
        Message memory message = Message({
            channel: 0x009D223Aad560e72282db9c0438Ef1ef2bf7703D,
            index: 51,
            fromChainId: 44,
            from: 0x0b001c95E86D64C1Ad6e43944C568A6C31b53887,
            toChainId: 421614,
            to: 0x0b001c95E86D64C1Ad6e43944C568A6C31b53887,
            gasLimit: 10000,
            encoded: hex"6038088888893649"
        });
        assertEq(bytes32(0xf57d7bb05db4caa05a97937786fcab99009d70b705a850ea478c4b73bc4e048f), hash(message));
    }
}
