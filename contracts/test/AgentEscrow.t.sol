// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {AgentEscrow} from "../src/core/AgentEscrow.sol";

contract AgentEscrowTest is Test {
    AgentEscrow public escrow;

    // Simulated creator (matches real deployer in production)
    address public creator = 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10;
    address public client  = address(0x1111);
    address public agent   = address(0x2222);

    function setUp() public {
        vm.prank(creator);
        escrow = new AgentEscrow(creator);
    }

    function test_CreateJobAndCompleteTask() public {
        uint256 budget = 1 ether;
        uint256 wage   = 0.1 ether;

        vm.deal(client, budget);
        vm.prank(client);
        uint256 jobId = escrow.createJob{value: budget}(agent, wage, "Test job");

        // Agent completes one task
        vm.prank(agent);
        escrow.completeTask(jobId, keccak256("work output"), "First task done");

        assertEq(agent.balance, wage);
        assertEq(escrow.agentEarnings(agent), wage);

        AgentEscrow.Job memory job = escrow.getJob(jobId);
        assertEq(job.tasksCompleted, 1);
        assertEq(job.remainingBudget, budget - wage);
        assertTrue(job.active);
    }

    function test_OnlyAgentCanComplete() public {
        vm.deal(client, 1 ether);
        vm.prank(client);
        uint256 jobId = escrow.createJob{value: 1 ether}(agent, 0.1 ether, "");

        vm.prank(client); // wrong caller
        vm.expectRevert("Only assigned agent");
        escrow.completeTask(jobId, bytes32(0), "");
    }

    function test_OwnerIsCreator() public {
        assertEq(escrow.owner(), creator);
    }
}