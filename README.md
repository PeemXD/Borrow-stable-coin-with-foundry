# borrow-stable-coin-with-foundry

## Documentation of foundry

https://book.getfoundry.sh/

## How to start new project

### Init project

```shell
$ forge init .
$ rm src/*.sol test/*.sol script/*.sol # delete the existing contract, test and script:
$ forge install openzeppelin/openzeppelin-contracts
$ forge install smartcontractkit/foundry-chainlink-toolkit
```

### Remap (option)

```shell
$ forge remappings > remappings.txt
```

### write contract and test

### Set up .env

1. BASE_SEPOLIA_RPC=https://sepolia.base.org
1. OP_SEPOLIA_RPC=https://sepolia.optimism.io
1. OP_ETH_USD=0x61Ec26aA57019C486B10502285c5A3D4A4750AD7
1. ETHERSCAN_APIKEY=
1. SENDER_ADDRESS=

Get Price Feed Contract Addresses from chainlink [HERE](https://docs.chain.link/data-feeds/price-feeds/addresses)

> [!IMPORTANT]
> Base sepolia don't have eth/usd contract address

### Loading environment variables

```shell
$ source .env
```

### Storing your private key

```shell
$ cast wallet import deployer --interactive
$ cast wallet list
```

### Deploy and Verify cotract with sourcify

```shell
# to op sepolia
$ forge script script/PepoStablecoin.s.sol:PepoStablecoinScript --rpc-url $OP_SEPOLIA_RPC --broadcast --verify --verifier sourcify -vvvv --account deployer --sender $SENDER_ADDRESS

# to base sepolia
$ forge script script/PepoStablecoin.s.sol:PepoStablecoinScript --rpc-url $BASE_SEPOLIA_RPC --broadcast --verify --verifier sourcify -vvvv --account deployer --sender $SENDER_ADDRESS
```

### Cast

```shell
$ cast <subcommand>
$ cast call <DEPLOYED_ADDRESS> --rpc-url $P_SEPOLIA_RPC "getLatestPrice()"
```
