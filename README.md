# Ethereum Social Contract

This repository contains the [`PrivacyPool` contract](apps/contracts/contracts/PrivacyPool.sol) which enables private ERC20 transfers while maintaining legal compliance by requiring the divulgence of secrets to a trusted committee that will respond to requests from law enforcement orders.

If the backend server is not available, deposited funds may be recovered by performing a public withdrawal that does not break the transfer link.
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

TAZ contracts use the latest version of the [`Semaphore.sol`](https://goerli.etherscan.io/address/0xE585f0Db9aB24dC912404DFfb9b28fb8BF211fA6) contract, deployed on the Goerli testnet. The web app uses Next.js and allows users with a valid Semaphore ID to join the TAZ group and generate Semaphore proofs to post anonymous questions and answers, or to make art. Proofs related to the Q&A part are validated on-chain, while proofs related to artworks are validated off-chain and final canvases are posted as NFTs. Users can also vote anonymously for their favorite artworks.

⚠️ The TAZ apps are experimental and the code is not well tested. For more information visit [taz.appliedzkp.org](https://taz.appliedzkp.org) or see our [Notion site](https://pse-team.notion.site/About-the-TAZ-app-1ae2793046414468b56472f43725961e).

## 🛠 Install

Clone this repository:

```bash
git clone https://github.com/semaphore-protocol/taz-apps.git
```

And install the dependencies:

```bash
cd taz-apps && yarn
```

## 📜 Usage

Web app and contracts need their env variables. For each of them, copy the `.env.example` file as `.env`:

```bash
cd apps/web-app # and apps/contracts
cp .env.example .env
```

And add your environment variables.

### Start the web-app

Run the following command to run a local web app:

```bash
yarn start:web-app
```

### Test the contracts

Contracts can be tested with the following command:

```bash
yarn test:contracts
```

### Code quality and formatting

Run [ESLint](https://eslint.org/) to analyze the code and catch bugs:

```bash
yarn lint
```

Run [Prettier](https://prettier.io/) to check formatting rules:

```bash
yarn prettier
```

or to automatically format the code:

```bash
yarn prettier:write
```
