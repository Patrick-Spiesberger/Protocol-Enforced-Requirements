const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RequirementManager", function () {
    let RequirementManager, requirementManager;
    let PreRequirement, MainRequirement, PostRequirement, Condition;
    let preRequirement, mainRequirement, postRequirement;
    let condition1, condition2, condition3, condition4;
    let owner, addr1, addr2;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy the Condition contract
        Condition = await ethers.getContractFactory("Condition");
        condition1 = await Condition.deploy(true); // Fulfilled
        condition2 = await Condition.deploy(false); // Not fulfilled
        condition3 = await Condition.deploy(true); // Fulfilled
        condition4 = await Condition.deploy(false); // Not fulfilled

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

        // Register the requirements for the owner
        await requirementManager.registerRequirement(preRequirement.address, mainRequirement.address, postRequirement.address);
    });

    it("Should correctly handle multiple conditions in a single requirement", async function () {
        // Add an additional condition to the PreRequirement and PostRequirement
        await preRequirement.addCondition(condition4.address);
        await postRequirement.addCondition(condition4.address);

        // Re-register the updated requirements
        await requirementManager.registerRequirement(preRequirement.address, mainRequirement.address, postRequirement.address);

        const [preCommitment, mainCommitment, postCommitment] = await requirementManager.getCommitmentIndicators(owner.address);
        
        // preRequirement should not be fulfilled because condition4 is not fulfilled
        expect(preCommitment).to.equal(false);
        // mainRequirement should not be fulfilled (condition2 is not fulfilled)
        expect(mainCommitment).to.equal(false);
        // postRequirement should not be fulfilled because condition4 is not fulfilled
        expect(postCommitment).to.equal(false);
    });

    it("Should allow re-registering requirements and updating conditions", async function () {
        // Modify the conditions and re-register
        await preRequirement.removeCondition(condition1.address);
        await preRequirement.addCondition(condition2.address); // Unfulfilled condition

        await requirementManager.registerRequirement(preRequirement.address, mainRequirement.address, postRequirement.address);

        const [preCommitment, mainCommitment, postCommitment] = await requirementManager.getCommitmentIndicators(owner.address);

        expect(preCommitment).to.equal(false); // PreRequirement should be unfulfilled now
        expect(mainCommitment).to.equal(false); // MainRequirement remains unfulfilled
        expect(postCommitment).to.equal(true); // PostRequirement remains fulfilled
    });

    it("Should revert when registering a requirement with an invalid contract address", async function () {
        // Try to register with a zero address, which is invalid
        await expect(
            requirementManager.registerRequirement(ethers.constants.AddressZero, mainRequirement.address, postRequirement.address)
        ).to.be.revertedWith("Invalid contract address");

        // Try to register with a non-contract address
        await expect(
            requirementManager.registerRequirement(owner.address, mainRequirement.address, postRequirement.address)
        ).to.be.revertedWith("Invalid contract address");
    });

    it("Should not allow non-owner to delete a requirement", async function () {
        // addr1 attempts to delete owner's requirement
        await expect(
            requirementManager.connect(addr1).deleteRequirement()
        ).to.be.revertedWith("Ownable: caller is not the owner");

        // Owner should still be able to delete it
        await requirementManager.deleteRequirement();
        const encodedRequirement = await requirementManager.requirements(owner.address);
        expect(encodedRequirement).to.equal("0x"); // After deletion, it should be empty
    });

    it("Should revert when attempting to get a requirement from an unregistered address", async function () {
        // Attempt to get a requirement from addr1, who has not registered anything
        await expect(
            requirementManager.getRequirement(addr1.address)
        ).to.be.revertedWith("No requirement found for this address");
    });

    it("Should allow multiple addresses to register different requirements", async function () {
        // Register a different set of requirements for addr1
        const newPreReq = await PreRequirement.deploy();
        const newMainReq = await MainRequirement.deploy();
        const newPostReq = await PostRequirement.deploy();

        await newPreReq.addCondition(condition4.address); // Unfulfilled condition
        await newMainReq.addCondition(condition1.address); // Fulfilled condition
        await newPostReq.addCondition(condition2.address); // Unfulfilled condition

        await requirementManager.connect(addr1).registerRequirement(newPreReq.address, newMainReq.address, newPostReq.address);

        const [preCommitmentAddr1, mainCommitmentAddr1, postCommitmentAddr1] = await requirementManager.getCommitmentIndicators(addr1.address);
        
        // addr1's requirements
        expect(preCommitmentAddr1).to.equal(false); // newPreReq should be unfulfilled
        expect(mainCommitmentAddr1).to.equal(true); // newMainReq should be fulfilled
        expect(postCommitmentAddr1).to.equal(false); // newPostReq should be unfulfilled

        // Owner's requirements should remain unchanged
        const [preCommitmentOwner, mainCommitmentOwner, postCommitmentOwner] = await requirementManager.getCommitmentIndicators(owner.address);
        expect(preCommitmentOwner).to.equal(true); // Owner's PreRequirement is fulfilled
        expect(mainCommitmentOwner).to.equal(false); // Owner's MainRequirement is unfulfilled
        expect(postCommitmentOwner).to.equal(true); // Owner's PostRequirement is fulfilled
    });

    it("Should correctly handle complex conditions and fulfillments", async function () {
        // Add more complex conditions
        await mainRequirement.addCondition(condition1.address); // This should now make MainRequirement fulfilled
        await requirementManager.registerRequirement(preRequirement.address, mainRequirement.address, postRequirement.address);

        const [preCommitment, mainCommitment, postCommitment] = await requirementManager.getCommitmentIndicators(owner.address);
        expect(preCommitment).to.equal(true); // PreRequirement remains fulfilled
        expect(mainCommitment).to.equal(true); // MainRequirement should now be fulfilled (both conditions true)
        expect(postCommitment).to.equal(true); // PostRequirement remains fulfilled
    });
});
