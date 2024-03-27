// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import {ORMP} from "../../src/ORMP.sol";
import {Relayer} from "../../src/eco/Relayer.sol";
import {Oracle} from "../../src/eco/Oracle.sol";

interface III {
    function PROTOCOL() external view returns (address);
    function isApproved(address operator) external view returns (bool);
    function setApproved(address operator, bool approve) external;
    function owner() external view returns (address);
    function changeOwner(address owner_) external;
    function setter() external view returns (address);
    function changeSetter(address setter_) external;
}

/// @title Deploy
/// @notice Script used to deploy a ORMP protocol. The entire protocol is deployed within the `run` function.
///         To add a new contract to the protocol, add a public function that deploys that individual contract.
///         Then add a call to that function inside of `run`.
contract Deploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address ORMP_ADDR;
    bytes32 ORMP_SALT;
    address ORACLE_ADDR;
    bytes32 ORACLE_SALT;
    address RELAYER_ADDR;
    bytes32 RELAYER_SALT;

    string c3;
    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;
    address oracleOperator;
    address relayerOperator;

    /// @notice The name of the script, used to ensure the right deploy artifacts
    ///         are used.
    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy.c"));
        outputName = "deploy.a";
        config = ScriptTools.readInput(instanceId);
        c3 = ScriptTools.readInput("../c3");

        ORMP_ADDR = c3.readAddress(".ORMP_ADDR");
        ORMP_SALT = c3.readBytes32(".ORMP_SALT");
        ORACLE_ADDR = c3.readAddress(".ORMPORACLE_ADDR");
        ORACLE_SALT = c3.readBytes32(".ORMPORACLE_SALT");
        RELAYER_ADDR = c3.readAddress(".RELAYER_ADDR");
        RELAYER_SALT = c3.readBytes32(".RELAYER_SALT");

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
        oracleOperator = config.readAddress(".ORACLE_OPERATOR");
        relayerOperator = config.readAddress(".RELAYER_OPERATOR");
    }

    /// @notice Deploy all of the contracts
    function run() public {
        require(deployer == msg.sender, "!deployer");

        deployProtocol();
        deployOralce();
        deployRelayer();

        setConfig();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "ORMP", ORMP_ADDR);
        ScriptTools.exportContract(outputName, "ORACLE", ORACLE_ADDR);
        ScriptTools.exportContract(outputName, "RELAYER", RELAYER_ADDR);
    }

    /// @notice Deploy the protocol
    function deployProtocol() public broadcast returns (address) {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address ormp = _deploy3(ORMP_SALT, initCode);
        require(ormp == ORMP_ADDR, "!ormp");
        require(III(ormp).setter() == deployer, "!deployer");
        console.log("ORMP    deployed at: %s", ormp);
        return ormp;
    }

    /// @notice Deploy the Oracle
    function deployOralce() public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP_ADDR));
        address oracle = _deploy3(ORACLE_SALT, initCode);
        require(oracle == ORACLE_ADDR, "!oracle");

        require(III(oracle).owner() == deployer);
        require(III(oracle).PROTOCOL() == ORMP_ADDR);
        console.log("Oracle  deployed at: %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer() public broadcast returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP_ADDR));
        address relayer = _deploy3(RELAYER_SALT, initCode);
        require(relayer == RELAYER_ADDR, "!relayer");

        require(III(relayer).owner() == deployer);
        require(III(relayer).PROTOCOL() == ORMP_ADDR);
        console.log("Relayer deployed at: %s", relayer);
        return relayer;
    }

    /// @notice Set the protocol config
    function setConfig() public broadcast {
        ORMP(ORMP_ADDR).setDefaultConfig(ORACLE_ADDR, RELAYER_ADDR);
        (address o, address r) = ORMP(ORMP_ADDR).defaultUC();
        require(o == ORACLE_ADDR, "!oracle");
        require(r == RELAYER_ADDR, "!relayer");

        III(ORACLE_ADDR).setApproved(oracleOperator, true);
        require(III(ORACLE_ADDR).isApproved(oracleOperator), "!o-operator");
        III(RELAYER_ADDR).setApproved(relayerOperator, true);
        require(III(RELAYER_ADDR).isApproved(relayerOperator), "!r-operator");

        // III(ORMP_ADDR).changeSetter(dao);
        // require(III(ORMP_ADDR).setter() == dao, "!dao");

        // III(ORACLE_ADDR).changeOwner(dao);
        // require(III(ORACLE_ADDR).owner() == dao, "!dao");

        // III(RELAYER_ADDR).changeOwner(dao);
        // require(III(RELAYER_ADDR).owner() == dao, "!dao");
    }
}
