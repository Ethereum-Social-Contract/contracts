import { task, types } from "hardhat/config"

task("deploy:mock-token", "Deploy a MockToken contract")
    .addOptionalParam("logs", "Print the logs", true, types.boolean)
    .setAction(async ({ logs }, { ethers }) => {
        const contract = await ethers.getContractFactory("MockToken")
        const token = await contract.deploy()
        await token.deployed()
        if (logs) {
            console.log("--------------------------------------------------------------------")
            console.log(
                `TASK deployMockToken | MockToken contract has been deployed to: ${
                    token.address
                } with owner: ${await contract.signer.getAddress()}`
            )
            console.log("--------------------------------------------------------------------")
        }
        return token
    })

