const { expect } = require("chai")
const { ethers } = require("hardhat")
const BigNumber = require("bignumber.js")

describe("JPEGRoyale", function () {
    it("should generate random number", async function () {
        const _BASEFEE = BigInt(100000000000000000)
        const _GASPRICELINK = BigInt(1000000000)
        const _KEYHASH = "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc"
        const value = new BigNumber("1000000000000000000")

        const VRFCoordinatorV2Mock = await hre.ethers.getContractFactory("VRFCoordinatorV2Mock")
        const vrfCoordinatorV2MockDeployed = await VRFCoordinatorV2Mock.deploy(
            _BASEFEE,
            _GASPRICELINK
        )

        await vrfCoordinatorV2MockDeployed.deployed()

        const subscriptionId = vrfCoordinatorV2MockDeployed.createSubscription()
        await vrfCoordinatorV2MockDeployed.fundSubscription(subscriptionId, { value: value })

        const JPEGRoyale = await hre.ethers.getContractFactory("JPEGRoyale")
        const jpegRoyaleDeployed = await JPEGRoyale.deploy(
            vrfCoordinatorV2MockDeployed.address,
            subscriptionId,
            _KEYHASH
        )

        await jpegRoyaleDeployed.deployed()

        await vrfCoordinatorV2MockDeployed.addConsumer(subscriptionId, jpegRoyaleDeployed.address)

        const request_id = await jpegRoyaleDeployed.requestRandomWords()
        console.log(request_id)

        await vrfCoordinatorV2MockDeployed.fulfillRandomWords(
            request_id,
            jpegRoyaleDeployed.address
        )

        await jpegRoyaleDeployed.s_requests[request_id].fulfilled

        expect(await jpegRoyaleDeployed.s_requests[request_id].fulfilled).to.equal(true)
        expect(await jpegRoyaleDeployed.s_requests[request_id].randomWords).to.not.equal(0)
    })
})
