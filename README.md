# Ethereum: Protocol Enforced Requirements
:warning: This repository is incomplete and currently a work in progress (WIP). Please carefully evaluate the Smart Contracts provided here before using them.

## :fast_forward: Preamble
Protocol Enforced Requirements (PER) is a concept rooted in Protocol Enforced Proposer Commitments ([PEPC](https://ethresear.ch/t/unbundling-pbs-towards-protocol-enforced-proposer-commitments-pepc/13879/4)) and specifically requires the implementation of these commitments. For this approach, we are inclined towards an in-protocol solution for PEPC, particularly considering the Commitment-Satisfaction Committees ([CSC](https://ethresear.ch/t/commitment-satisfaction-committees-an-in-protocol-solution-to-pepc/17055)) as referenced in [EIP-7732](https://eips.ethereum.org/EIPS/eip-7732). An alternative approach is provided by 0xfuturistic with "[Emily](https://github.com/0xfuturistic/emily): A Protocol for Credible Commitments". 

## :fast_forward: Structure
### Requirement Manager
This repository includes a Smart Contract, `RequirementManager.sol`, which acts as a registry for requirements received by an entity (Applicant, Proposer, Builder) within the network, facilitating the management of these requirements. This Smart Contract stores encoded byte strings representing objects of the type `Requirement`. The goal is to allow an entity in the network to register an encoded requirement in the contract, with the decoded version and the entity’s address being stored within the contract. To verify whether a specific condition is met for:
1. The inclusion of a transaction, OR
2. The creation of a block, OR
3. The status of an entity,
   
the decoded requirement (including the properties discussed below) can be retrieved from the register. Each entity can create at most one `Requirement`, but they can also delete or modify parts of it. A `Requirement` remains valid until it is removed from the register. To avoid equivocation, we need to ensure, that a `Requirement`is finalized (using mechanisms like Gasper or SSF).

### Requirement
A `Requirement` is fundamentally divided into three sections:
1. **PreRequirements**: These requirements contain `Conditions` that must be met before the Main and PostRequirements can be evaluated. PreRequirements serve as a preliminary check to model conditions related to the entity rather than the block itself. A typical example of a `PreRequirement` is the condition `CommittedTo.sol`, which verifies whether a specific entity has registered a particular requirement in the `RequirementManager`.
2. **MainRequirement**: This type of requirement focuses on properties related to the block that needs to be verified. For instance, it is possible to create a condition that requires a builder to include a transaction at a specific position within the block.
3. **PostRequirement**: These requirements signify a status that must be present in the network. This status is managed in the form of a requirement, which can be considered as a promise. For example, a proposer might issue a requirement to produce an honest, censorship-free inclusion list. `PostRequirements` cannot be verified as a block or entity condition within the current slot, but can only be checked in the subsequent slot.

A `Requirement` is a bundle of these three sections, with each type of requirement containing a list of Conditions that must ALL be met. Verification is currently possible only at the `Condition` level and not within the `Requirement` itself.

### Condition
A `Condition` object must implement the `ICondition` interface. This interface includes an `isFulfilled` method, which defines the criteria under which the condition is considered met. We have already created appropriate conditions for all fields of a block accessible through the Solidity interface, and these can be found under `src/Conditions`.
An overview of the structure and the conditions can be found in the following UML diagram
![](images/per_uml.svg)

## :fast_forward: How to create a Requirement
To register a requirement in the `RequirementManager`, you first need to create a `Requirement` object that includes the necessary sections. Below is how you can initialize the sections:

```solidity
PreRequirement preRequirement = new PreRequirement();
MainRequirement mainRequirement = new MainRequirement(); 
PostRequirement postRequirement = new PostRequirement();
```

Each of these objects starts with an empty list of conditions.

After creating the `Requirement` object, you need to specify the conditions under which it will be fulfilled. You can either create a new condition (which must be deployed as a smart contract on the blockchain) or use an existing one.

Here’s an example of how to create a condition related to the block header:

```solidity
BlockHeaderConditions condition_example = new BlockHeaderConditions(
    42,
    address(0x1234567890abcdef1234567890abcdef12345678),
    8000000,
    1000000000,
    1,
    0,
    42
);
```

Once the condition is created, it can be added to the list of the respective (Pre, Main, Post) requirement using the `addCondition(Condition)` method. In the example above, this would look like:

```solidity
mainRequirement.addCondition(condition_example);
```

The requirement can then be created using the constructor as follows:

```solidity
requirement = new Requirement(
    preRequirement,
    mainRequirement,
    postRequirement
);
```
You can then call the `encodeRequirement()` function on this requirement to generate the encoded string, which can be registered in the `RequirementManager` via a transaction.
