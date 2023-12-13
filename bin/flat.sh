#! /usr/bin/env bash

set -eo pipefail

forge flatten src/ORMP.sol -o ./flat/ORMP.f.sol
forge flatten src/eco/Oracle.sol -o ./flat/Oracle.f.sol
forge flatten src/eco/Relayer.sol -o ./flat/Relayer.f.sol
