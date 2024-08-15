const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RequirementManager", function () {
    let RequirementManager, requirementManager;
    let PreRequirement, MainRequirement, PostRequirement, Condition;
    let preRequirement, mainRequirement, postRequirement;
    let condition1, condition2, condition3;
    let owner, addr1;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        [owner, addr1] = await ethers.getSigners();

        // Deploy the Condition contract
        Condition = await ethers.getContractFactory("Condition");
        condition1 = await Condition.deploy(true);
        condition2 = await Condition.deploy(false);
        condition3 = await Condition.deploy(true);

        // Deploy PreRequirement, MainRequirement, PostRequirement contracts
        PreRequirement = await ethers.getContractFactory("PreRequirement");
        MainRequirement = await ethers.getContractFactory("MainRequirement");
        PostRequirement = await ethers.getContractFactory("PostRequirement");

        preRequirement = await PreRequirement.deploy();
        mainRequirement = await MainRequirement.deploy();
        postRequirement = await PostRequirement.deploy();

        // Add conditions to each Requirement
        await preRequirement.addCondition(condition1.address);
        await mainRequirement.addCondition(condition2.address);
        await postRequirement.addCondition(condition3.address);

        // Deploy the RequirementManager contract
        RequirementManager = await ethers.getContractFactory("RequirementManager");
        requirementManager = await RequirementManager.deploy();

        // Register the requirements
        await requirementManager.registerRequirement(preRequirement.address, mainRequirement.address, postRequirement.address);
    });

    it("Should register a requirement for the owner address", async function () {
        const encodedRequirement = await requirementManager.requirements(owner.address);
        expect(encodedRequirement).to.not.equal("0x"); // Check that it is not empty
    });

    it("Should return the correct requirements for the owner address", async function () {
        const [preReq, mainReq, postReq] = await requirementManager.getRequirement(owner.address);
        expect(preReq).to.equal(preRequirement.address);
        expect(mainReq).to.equal(mainRequirement.address);
        expect(postReq).to.equal(postRequirement.address);
    });

    it("Should allow deleting a requirement for the owner address", async function () {
        await requirementManager.deleteRequirement();
        const encodedRequirement = await requirementManager.requirements(owner.address);
        expect(encodedRequirement).to.equal("0x"); // After deletion, it should be empty
    });

    it("Should return false for unfulfilled requirements", async function () {
        const [preCommitment, mainCommitment, postCommitment] = await requirementManager.getCommitmentIndicators(owner.address);
        expect(preCommitment).to.equal(true);
        expect(mainCommitment).to.equal(false); // Condition 2 is false
        expect(postCommitment).to.equal(true);
    });

    it("Should allow querying the requirements of another address", async function () {
        // Register a new set of requirements for addr1
        await requirementManager.connect(addr1).registerRequirement(preRequirement.address, mainRequirement.address, postRequirement.address);

        const [preReq, mainReq, postReq] = await requirementManager.getRequirement(addr1.address);
        expect(preReq).to.equal(preRequirement.address);
        expect(mainReq).to.equal(mainRequirement.address);
        expect(postReq).to.equal(postRequirement.address);
    });

    it("Should revert if there is no requirement for the given address", async function () {
        await expect(requirementManager.getRequirement(addr1.address)).to.be.revertedWith("No requirement found for this address");
    });
});
