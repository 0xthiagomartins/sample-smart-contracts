// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Governor.sol";
import "../src/token/DGYM.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract GovernorTest is Test {
    DeGymToken private token;
    TimelockController private timelock;
    GovernorContract private governor;
    address private owner = address(0x123);

    function setUp() public {
        token = new DeGymToken(1000 ether, 2000 ether);
        address[] memory proposers = new address[](1);
        proposers[0] = owner;
        address[] memory executors = new address[](1);
        executors[0] = owner;
        timelock = new TimelockController(1 days, proposers, executors, owner);
        governor = new GovernorContract(token, timelock);

        token.delegate(owner);
    }

    function testProposalLifecycle() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(token.setCap.selector, 3000);

        string memory description = "Increase cap";

        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            description
        );

        // Cast a vote
        governor.castVote(proposalId, 1);

        // Fast forward time to voting period end
        vm.warp(block.timestamp + governor.votingPeriod());

        // Queue the proposal
        governor.queue(
            targets,
            values,
            calldatas,
            keccak256(bytes(description))
        );

        // Fast forward time to timelock delay end
        vm.warp(block.timestamp + timelock.getMinDelay());

        // Execute the proposal
        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes(description))
        );

        // Check if the cap was updated
        assertEq(token.cap(), 3000 * 10 ** token.decimals());
    }
}
