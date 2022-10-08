# Ethereum Social Contract

This repository contains the [`PrivacyPool` contract](apps/contracts/contracts/PrivacyPool.sol) which enables private ERC20 transfers while maintaining legal compliance by requiring the divulgence of secrets to a trusted committee that will respond to requests from law enforcement orders.

If the backend server is not available, deposited funds may be recovered by performing a public withdrawal that does not break the transfer link.

| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

## 📜 Usage

Copy the `.env.example` file and rename it `.env`.

### Compile contracts

Compile the smart contracts with [Hardhat](https://hardhat.org/):

```bash
yarn compile
```

### Testing

Run [Mocha](https://mochajs.org/) to test the contracts:

```bash
yarn test
```

### Deploy contracts

Deploy a `PrivacyPool.sol` contract:

```bash
yarn deploy:privacy-pool --semaphoreContract 0xE585f0Db9aB24dC912404DFfb9b28fb8BF211fA6 --groupId 123456 --token 0x1111111111111111111111111111111111111111 --amount  1 --committeeKey 0x1111111111111111111111111111111111111111
```
