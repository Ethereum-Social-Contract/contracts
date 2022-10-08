import { task, types } from "hardhat/config"

task("deploy:privacy-pool", "Deploy a PrivacyPool contract")
    .addParam("semaphoreContract", "Address of the Semaphore contract", undefined, types.string)
    .addParam("groupId", "Group ID Number", undefined, types.string)
    .addParam("token", "Address of the Token contract", undefined, types.string)
    .addParam("amount", "Amount of the token to deposit", undefined, types.string)
    .addParam("committeeKey", "Address committee key", undefined, types.string)
    .addOptionalParam("logs", "Print the logs", true, types.boolean)
    .setAction(async ({ semaphoreContract, groupId, token, amount, committeeKey, logs }, { ethers }) => {
        const contract = await ethers.getContractFactory("PrivacyPool")
        const pool = await contract.deploy(semaphoreContract, groupId, token, amount, committeeKey)
        await pool.deployed()
        if (logs) {
            console.log("--------------------------------------------------------------------")
            console.log(
                `TASK deployPrivacyPool | PrivacyPool contract has been deployed to: ${
                    pool.address
                } with owner: ${await contract.signer.getAddress()}`
            )
            console.log("--------------------------------------------------------------------")
        }
        return pool
    })
