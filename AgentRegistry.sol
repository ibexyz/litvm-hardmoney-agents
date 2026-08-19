// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AgentRegistry
 * @notice Registry of authorized AI agents that can work in the Hard Money economy.
 * @dev Owner (creator) can register / pause agents.
 */
contract AgentRegistry is Ownable {
    struct AgentInfo {
        address agentAddress;
        string name;
        string metadataURI;       // IPFS or description
        bool active;
        uint256 registeredAt;
        uint256 totalJobs;
    }

    mapping(address => AgentInfo) public agents;
    address[] public agentList;

    event AgentRegistered(address indexed agent, string name);
    event AgentUpdated(address indexed agent, bool active);
    event AgentRemoved(address indexed agent);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Register a new AI agent (only owner / creator)
     */
    function registerAgent(
        address agent,
        string calldata name,
        string calldata metadataURI
    ) external onlyOwner {
        require(agent != address(0), "Invalid address");
        require(!agents[agent].active || agents[agent].agentAddress == address(0), "Already registered");

        agents[agent] = AgentInfo({
            agentAddress: agent,
            name: name,
            metadataURI: metadataURI,
            active: true,
            registeredAt: block.timestamp,
            totalJobs: 0
        });

        agentList.push(agent);
        emit AgentRegistered(agent, name);
    }

    function setAgentActive(address agent, bool active) external onlyOwner {
        require(agents[agent].agentAddress != address(0), "Not registered");
        agents[agent].active = active;
        emit AgentUpdated(agent, active);
    }

    function isActiveAgent(address agent) external view returns (bool) {
        return agents[agent].active;
    }

    function getAgentCount() external view returns (uint256) {
        return agentList.length;
    }

    function getAgent(address agent) external view returns (AgentInfo memory) {
        return agents[agent];
    }
}
