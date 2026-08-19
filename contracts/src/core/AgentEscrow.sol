// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AgentEscrow
 * @notice Core payment layer for Hard Money AI Agents on LitVM.
 *         Clients escrow zkLTC, agents complete tasks and get paid.
 * @dev Owner is set at deployment to the creator address.
 */
contract AgentEscrow is Ownable, ReentrancyGuard {
    struct Job {
        address client;
        address agent;
        uint256 totalBudget;
        uint256 wagePerTask;
        uint256 tasksCompleted;
        uint256 remainingBudget;
        bool active;
        string metadataURI;
    }

    uint256 public nextJobId;
    mapping(uint256 => Job) public jobs;
    mapping(address => uint256) public agentEarnings;

    event JobCreated(uint256 indexed jobId, address indexed client, address indexed agent, uint256 totalBudget, uint256 wagePerTask);
    event TaskCompleted(uint256 indexed jobId, address indexed agent, uint256 payment, bytes32 workHash, string summary);
    event JobClosed(uint256 indexed jobId, uint256 refunded);
    event EmergencyWithdraw(address indexed to, uint256 amount);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function createJob(address agent, uint256 wagePerTask, string calldata metadataURI) external payable nonReentrant returns (uint256 jobId) {
        require(msg.value > 0, "Must escrow zkLTC");
        require(agent != address(0), "Invalid agent");
        require(wagePerTask > 0, "Wage must be > 0");
        require(msg.value >= wagePerTask, "Budget too low for even one task");

        jobId = nextJobId++;
        jobs[jobId] = Job({
            client: msg.sender,
            agent: agent,
            totalBudget: msg.value,
            wagePerTask: wagePerTask,
            tasksCompleted: 0,
            remainingBudget: msg.value,
            active: true,
            metadataURI: metadataURI
        });

        emit JobCreated(jobId, msg.sender, agent, msg.value, wagePerTask);
    }

    function completeTask(uint256 jobId, bytes32 workHash, string calldata summary) external nonReentrant {
        Job storage job = jobs[jobId];
        require(job.active, "Job not active");
        require(msg.sender == job.agent, "Only assigned agent");
        require(job.remainingBudget >= job.wagePerTask, "Insufficient remaining budget");

        job.remainingBudget -= job.wagePerTask;
        job.tasksCompleted += 1;
        agentEarnings[msg.sender] += job.wagePerTask;

        (bool success, ) = payable(msg.sender).call{value: job.wagePerTask}("");
        require(success, "Payment failed");

        emit TaskCompleted(jobId, msg.sender, job.wagePerTask, workHash, summary);

        if (job.remainingBudget < job.wagePerTask) {
            job.active = false;
            emit JobClosed(jobId, job.remainingBudget);
        }
    }

    function closeJob(uint256 jobId) external nonReentrant {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client || msg.sender == owner(), "Not authorized");
        require(job.active, "Already closed");

        job.active = false;
        uint256 refund = job.remainingBudget;
        job.remainingBudget = 0;

        if (refund > 0) {
            (bool success, ) = payable(job.client).call{value: refund}("");
            require(success, "Refund failed");
        }

        emit JobClosed(jobId, refund);
    }

    function getJob(uint256 jobId) external view returns (Job memory) {
        return jobs[jobId];
    }

    function emergencyWithdraw(address to) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(to).call{value: balance}("");
        require(success, "Withdraw failed");
        emit EmergencyWithdraw(to, balance);
    }

    receive() external payable {}
}