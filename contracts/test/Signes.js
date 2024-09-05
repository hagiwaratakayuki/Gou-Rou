const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Sign", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployFixture() {
        const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
        const ONE_GWEI = 1_000_000_000;


        // Contracts are deployed using the first signer/account by default
        const [operater] = await ethers.getSigners();

        const Signs = await ethers.getContractFactory("contracts/core/storage/SignStorage.sol:SignStorage");
        const signs = await Signs.deploy(operater);

        return { signs, Signs };
    }

    describe("Deployment", function () {
        it("Should set the right unlockTime", async function () {
            const { signs, Signs } = await loadFixture(deployFixture);
            return;
            const [truster, signer, owner, ownerSigner, contAddress, user] = await ethers.getSigners();
            await signs.insertOrUpdateSigner(signer.address, "", truster)

            const ownerHash = ethers.hashMessage(owner.address)
            const { default: hexToArrayBuffer } = await import("hex-to-array-buffer");

            const ownerBynaryAddress = new Uint8Array(hexToArrayBuffer(owner.address.replace(/^0x/i, "")))

            const ownerSignature = await signer.signMessage(ownerBynaryAddress)

            console.log((await signs.connect(signer).addTrust(/*ownerHash,*/ ownerSignature, owner, truster, 10)));
            return
            await signs.connect(owner).insertOrUpdateSigner(ownerSigner.address, "", owner);


            //const contHash = ethers.keccak256(contAddress.address)
            const contSignature = await ownerSigner.signMessage(contHash)

            console.log((await signs.connect(ownerSigner).addTrust(/*contHash,*/ contSignature, contAddress, owner, 10)));
            console.log((await signs.connect(user).checkTrust(owner, contAddress, truster, { value: 20 })));

            /*const digest = ethers.hashMessage("this is test")
            console.log(await signs.verify(digest, signature))
            console.log(await (signs.insertOrUpdateSigner(String(otherAccount.address))))
            console.log(String(otherAccount.address))
            console.log(await (signs.getSignAccount()))*/


        });
    })
})