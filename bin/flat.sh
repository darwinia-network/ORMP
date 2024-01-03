#! /usr/bin/env bash

set -eo pipefail

rm -rf flat/
mkdir -p flat/

forge flatten src/ORMP.sol -o ./flat/ORMP.f.sol
forge flatten src/eco/OracleV2.sol -o ./flat/OracleV2.f.sol
forge flatten src/eco/Relayer.sol -o ./flat/Relayer.f.sol
