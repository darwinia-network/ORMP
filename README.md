# ORMP
Oracle and Relayer based Message Protocol.

## Deployments
### Canonical Cross-chain Deployment Addresses
|  Contract  |  Canonical Cross-chain Deployment Address  |
|------------|--------------------------------------------|
| ORMP       | 0x00000000001523057a05d6293C1e5171eE33eE0A |
| Oracle     | 0x00000000046bc530804d66B6b64f7aF69B4E4E81 |
| Relayer    | 0x0000000000808fE9bDCc1d180EfbF5C53552a6b1 |
| MsgDAO     | 0x000000000879926D12aF396788C0785B7e581e53 |

#### Tron shasta
| Contract     | Deployment Address                 |
| ------------ | ---------------------------------- |
| ORMP         | TXzW7Zo6CNAS2c6VKJx1xpfeGxcshQGHMm |
| Oracle       | TL8opa8ZgxpPhWm4CW7xxkuZWcbERxFYNv |
| Relayer      | TXoHifzQNtyfhGckxK4ZHp9w7yim8iZXZ8 |

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
