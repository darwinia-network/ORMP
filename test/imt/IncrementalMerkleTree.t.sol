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
import "../../src/imt/IncrementalMerkleTree.sol";

contract IncrementalMerkleTreeTest is Test {
    function test_branchRoot() public {
        bytes32 leaf = 0xf57d7bb05db4caa05a97937786fcab99009d70b705a850ea478c4b73bc4e048f;
        bytes32[32] memory proof = [
            bytes32(0x0aa4bec9779f0d36aacec2d5f48f90ac4dcebf0c14069b9969cef9413094a24d),
            bytes32(0xe21d33754cd57548aa4490d18b1478acfb81d7062d16b0974dc79e2761f65719),
            bytes32(0x39ae4c335148e868f1140fa1bc9e40f6452d045d2ce8f05ec75996ec43a5ae3b),
            bytes32(0x3a9b29fd107c8a5f53f5c74cae9f9bc89210bac09dc5d88c8486eed6dadd99e8),
            bytes32(0xfd9947deff40d119257e0bd3814bd5e15af00e5c6cac7bc298a8b96316a8a5b1),
            bytes32(0xb9194a38215a5fed7ecd084e2775ed2ff6c3afdc93ad6b77563c100aa08f0a10),
            bytes32(0xb4c2bcd6dc43e38277ab78949460526c2eee8a6ddae69913895ec34549a7f45f),
            bytes32(0x574aea2952785bca474f4a3ad6de5a69c5f3abe57839bb1cf3b7f60c3193fb3a),
            bytes32(0x9867cc5f7f196b93bae1e27e6320742445d290f2263827498b54fec539f756af),
            bytes32(0xcefad4e508c098b9a7e1d8feb19955fb02ba9675585078710969d3440f5054e0),
            bytes32(0xf9dc3e7fe016e050eff260334f18a5d4fe391d82092319f5964f2e2eb7c1c3a5),
            bytes32(0xf8b13a49e282f609c317a833fb8d976d11517c571d1221a265d25af778ecf892),
            bytes32(0x3490c6ceeb450aecdc82e28293031d10c7d73bf85e57bf041a97360aa2c5d99c),
            bytes32(0xc1df82d9c4b87413eae2ef048f94b4d3554cea73d92b0f7af96e0271c691e2bb),
            bytes32(0x5c67add7c6caf302256adedf7ab114da0acfe870d449a3a489f781d659e8becc),
            bytes32(0xda7bce9f4e8618b6bd2f4132ce798cdc7a60e7e1460a7299e3c6342a579626d2),
            bytes32(0x2733e50f526ec2fa19a22b31e8ed50f23cd1fdf94c9154ed3a7609a2f1ff981f),
            bytes32(0xe1d3b5c807b281e4683cc6d6315cf95b9ade8641defcb32372f1c126e398ef7a),
            bytes32(0x5a2dce0a8a7f68bb74560f8f71837c2c2ebbcbf7fffb42ae1896f13f7c7479a0),
            bytes32(0xb46a28b6f55540f89444f63de0378e3d121be09e06cc9ded1c20e65876d36aa0),
            bytes32(0xc65e9645644786b620e2dd2ad648ddfcbf4a7e5b1a3a4ecfe7f64667a3f0b7e2),
            bytes32(0xf4418588ed35a2458cffeb39b93d26f18d2ab13bdce6aee58e7b99359ec2dfd9),
            bytes32(0x5a9c16dc00d6ef18b7933a6f8dc65ccb55667138776f7dea101070dc8796e377),
            bytes32(0x4df84f40ae0c8229d0d6069e5c8f39a7c299677a09d367fc7b05e3bc380ee652),
            bytes32(0xcdc72595f74c7b1043d0e1ffbab734648c838dfb0527d971b602bc216c9619ef),
            bytes32(0x0abf5ac974a1ed57f4050aa510dd9c74f508277b39d7973bb2dfccc5eeb0618d),
            bytes32(0xb8cd74046ff337f0a7bf2c8e03e10f642c1886798d71806ab1e888d9e5ee87d0),
            bytes32(0x838c5655cb21c6cb83313b5a631175dff4963772cce9108188b34ac87c81c41e),
            bytes32(0x662ee4dd2dd7b2bc707961b1e646c4047669dcb6584f0d8d770daf5d7e7deb2e),
            bytes32(0x388ab20e2573d171a88108e79d820e98f26c0b84aa8b2f4aa4968dbb818ea322),
            bytes32(0x93237c50ba75ee485f4c22adf2f741400bdf8d6a9cc7df7ecae576221665d735),
            bytes32(0x8448818bb4ae4562849e949e17ac16e0be16688e156b5cf15e098c627c0056a9)
        ];
        uint256 index = 51;
        bytes32 root = IncrementalMerkleTree.branchRoot(leaf, proof, index);
        assertEq(root, 0x22e1cff2fe32825f6bb0eede7d619e1ffc8f4989cf7432dce765df0a620b3a12);
    }
}
