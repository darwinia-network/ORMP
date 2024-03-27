# ORMP
Oracle and Relayer based Message Protocol.

## V1 Deployments
### Canonical Cross-chain Deployment Addresses
|  Contract  |  Canonical Cross-chain Deployment Address  |
|------------|--------------------------------------------|
| ORMP       | 0x00000000001523057a05d6293C1e5171eE33eE0A |
| ORMPOracle | 0x0000000003ebeF32D8f0ED406a5CA8805c80AFba |
| Relayer    | 0x0000000000808fE9bDCc1d180EfbF5C53552a6b1 |
| MsgDAO     | 0x000000000879926D12aF396788C0785B7e581e53 |

## Supported Chains
### Mainnet
- Arbitrum
- Blast
- Crab
- Darwinia
- Ethereum
- Polygon

### Testnet
- Arbitrum Sepolia
- Pangolin
- Sepolia

## Usage
To install with [**Foundry**](https://github.com/gakonst/foundry):
```sh
forge install darwinia-network/ORMP
```

To install with [**Hardhat**](https://github.com/nomiclabs/hardhat) or [**Truffle**](https://github.com/trufflesuite/truffle):
```sh
npm install @darwinia/ormp
```

## Install 
To install dependencies and compile contracts:
```sh
git clone --recurse-submodules https://github.com/darwinia-network/ORMP.git && cd ORMP
make tools
make
```
