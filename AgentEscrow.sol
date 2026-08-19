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
    // ============ Structs ============

    struct Job {
        address client;
        address agent;
        uint256 totalBudget;       // total zkLTC escrowed
        uint256 wagePerTask;       // payment per completed task
        uint256 tasksCompleted;
        uint256 remainingBudget;
        bool active;
        string metadataURI;        // optional IPFS / description
    }

    // ============ State ============

    uint256 public nextJobId;
    mapping(uint256 => Job) public jobs;

    // agent => total earnings
    mapping(address => uint256) public agentEarnings;

    // ============ Events ============

    event JobCreated(
        uint256 indexed jobId,
        address indexed client,
        address indexed agent,
        uint256 totalBudget,
        uint256 wagePerTask
    );

    event TaskCompleted(
        uint256 indexed jobId,
        address indexed agent,
        uint256 payment,
        bytes32 workHash,
        string summary
    );

    event JobClosed(uint256 indexed jobId, uint256 refunded);
    event EmergencyWithdraw(address indexed to, uint256 amount);

    // ============ Constructor ============

    /**
     * @param initialOwner The creator / deployer address
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    // ============ Core Functions ============

    /**
     * @notice Create a new job and escrow zkLTC
     * @param agent The AI agent address that will perform the work
     * @param wagePerTask Payment in zkLTC (wei) per completed task
     * @param metadataURI Optional description / IPFS hash
     */
    function createJob(
        address agent,
        uint256 wagePerTask,
        string calldata metadataURI
    ) external payable nonReentrant returns (uint256 jobId) {
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

    /**
     * @notice Agent submits completed work and receives payment
     * @param jobId The job ID
     * @param workHash keccak256 hash of the work output (for verification)
     * @param summary Short human-readable summary
     */
    function completeTask(
        uint256 jobId,
        bytes32 workHash,
        string calldata summary
    ) external nonReentrant {
        Job storage job = jobs[jobId];
        require(job.active, "Job not active");
        require(msg.sender == job.agent, "Only assigned agent");
        require(job.remainingBudget >= job.wagePerTask, "Insufficient remaining budget");

        job.remainingBudget -= job.wagePerTask;
        job.tasksCompleted += 1;
        agentEarnings[msg.sender] += job.wagePerTask;

        // Pay the agent immediately in zkLTC
        (bool success, ) = payable(msg.sender).call{value: job.wagePerTask}("");
        require(success, "Payment failed");

        emit TaskCompleted(jobId, msg.sender, job.wagePerTask, workHash, summary);

        // Auto-close if budget is exhausted
        if (job.remainingBudget < job.wagePerTask) {
            job.active = false;
            emit JobClosed(jobId, job.remainingBudget);
        }
    }

    /**
     * @notice Client can close the job and get remaining budget back
     */
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

    // ============ View Functions ============

    function getJob(uint256 jobId) external view returns (Job memory) {
        return jobs[jobId];
    }

    // ============ Emergency (Owner only) ============

    function emergencyWithdraw(address to) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(to).call{value: balance}("");
        require(success, "Withdraw failed");
        emit EmergencyWithdraw(to, balance);
    }

    receive() external payable {}
}
