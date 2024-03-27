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

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import "../../src/Verifier.sol";
import "../../src/ORMP.sol";
import "../../src/eco/Oracle.sol";
import "../../src/eco/Relayer.sol";

contract ORMPBenchmarkTest is Test {
    using Chains for uint256;

    ORMP ormp = ORMP(0x00000000001523057a05d6293C1e5171eE33eE0A);
    Oracle oracle = Oracle(payable(0x0000000003ebeF32D8f0ED406a5CA8805c80AFba));
    Relayer relayer = Relayer(payable(0x0000000000808fE9bDCc1d180EfbF5C53552a6b1));

    address immutable self = address(this);
    uint256 chain1 = Chains.Darwinia;
    uint256 chain2 = Chains.Arbitrum;

    function test_send_fuzz1(bytes calldata encoded) public {
        perform_send(chain1, chain2, encoded);
    }

    function test_send_fuzz2(bytes calldata encoded) public {
        perform_send(chain2, chain1, encoded);
    }

    function test_recv_fuzz1(bytes calldata encoded) public {
        test_recv(chain1, chain2, encoded);
    }

    function test_recv_fuzz2(bytes calldata encoded) public {
        test_recv(chain2, chain1, encoded);
    }

    function test_recv(uint256 fromChainId, uint256 toChainId, bytes calldata encoded) internal {
        perform_send(fromChainId, toChainId, encoded);

        Message memory message = Message({
            channel: address(ormp),
            index: ormp.messageCount() - 1,
            fromChainId: fromChainId,
            from: self,
            toChainId: toChainId,
            to: self,
            gasLimit: 0,
            encoded: encoded
        });
        perform_recv(message);
    }

    function perform_recv(Message memory message) public {
        bytes32 root = ormp.root();
        uint256 blockNumber = block.number;
        Verifier.Proof memory proof =
            Verifier.Proof({blockNumber: block.number, messageIndex: message.index, messageProof: ormp.prove()});

        vm.createSelectFork(message.toChainId.toChainName());
        vm.store(address(oracle), bytes32(uint256(0)), bytes32(uint256(uint160(self))));
        assertEq(oracle.owner(), self);
        vm.prank(address(oracle.owner()));
        oracle.importMessageRoot(message.fromChainId, blockNumber, root);

        vm.prank(address(relayer));
        ormp.recv(message, abi.encode(proof));
    }

    function perform_send(uint256 fromChainId, uint256 toChainId, bytes calldata encoded) public {
        vm.createSelectFork(fromChainId.toChainName());
        uint256 f = ormp.fee(toChainId, self, 0, encoded, "");
        ormp.send{value: f}(toChainId, self, 0, encoded, self, "");
    }
}
