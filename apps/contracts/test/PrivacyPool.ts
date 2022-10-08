/* eslint-disable no-console */
/* eslint-disable no-unused-expressions */
/* eslint-disable no-undef */

import { expect } from "chai"
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs"
import { run, ethers } from "hardhat"
import { Identity } from "@semaphore-protocol/identity"
import { keccak256 } from "@ethersproject/keccak256"
import { toUtf8Bytes } from "@ethersproject/strings"
import { SEMAPHORE_CONTRACT } from "../config/goerli.json"

const GROUP_ID = '123456';
const DEPOSIT_AMOUNT = '1';
const identitySeed = "sample-identity-seed";
const abi = require("../artifacts/contracts/PrivacyPool.sol/PrivacyPool.json").abi;

describe("PrivacyPool", () => {
  let token: any;
  let contract: any;
  let signer1: any;
  let signer2: any;

  before(async () => {
    ;[signer1, signer2] = await ethers.getSigners()

    token = await run("deploy:mock-token", {
      logs: true
    })
    contract = await run("deploy:privacy-pool", {
      semaphoreContract: SEMAPHORE_CONTRACT,
      groupId: GROUP_ID,
      token: token.address,
      amount: DEPOSIT_AMOUNT,
      logs: true
    })
  });

  describe("#deposit", () => {
    it("Should deposit the token", async () => {
      const mint  = token.connect(signer1).mint(signer1.address, DEPOSIT_AMOUNT);
      await expect(mint).to.not.be.reverted
      // TODO approve

      const identity = new Identity(identitySeed)
      const identityCommitment = identity.generateCommitment()
      const depositTx = contract.connect(signer1).deposit(identityCommitment);
      await expect(depositTx).to.not.be.reverted
    });
  });

  describe("#withdraw", () => {
    it("Should withdraw privately", async () => {
      const signal = ethers.utils.id('Some test signal').slice(35)

      const proofElements = await run("create:proof", {
          identitySeed,
          groupId: GROUP_ID,
          signal,
          externalNullifier: Math.round(Math.random() * 1000000000),
          logs: false
      })

      const tx = contract
          .connect(signer1)
          .replyToMessage(
              parentMessageId,
              messageContent,
              proofElements.groupId,
              proofElements.merkleTreeRoot,
              proofElements.signalBytes32,
              proofElements.nullifierHash,
              proofElements.externalNullifier,
              proofElements.solidityProof,
              { gasLimit: 1500000 }
          )

      await expect(tx).to.emit(contract, "MessageAdded").withArgs(parentMessageId, anyValue, messageContent)
    });
  });
});
