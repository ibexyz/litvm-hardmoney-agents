// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {AgentEscrow} from "../src/core/AgentEscrow.sol";
import {AgentRegistry} from "../src/core/AgentRegistry.sol";

/**
 * @title Deploy
 * @notice Deploys core Hard Money Agent contracts to LitVM LiteForge
 *
 * Creator / Owner address:
 * 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10
 *
 * IMPORTANT:
 * Run this script using the private key of the address above
 * so that msg.sender becomes the owner of both contracts.
 */
contract Deploy is Script {
    // Expected creator address (for verification)
    address constant EXPECTED_CREATOR = 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10;

    function run() external {
        address deployer = msg.sender;

        console2.log("========================================");
        console2.log("LitVM Hard Money Agents - Deployment");
        console2.log("========================================");
        console2.log("Deployer / Creator :", deployer);
        console2.log("Expected Creator   :", EXPECTED_CREATOR);
        console2.log("Chain ID           :", block.chainid);
        console2.log("========================================");

        require(deployer == EXPECTED_CREATOR, "Wrong deployer wallet! Use the correct private key.");

        vm.startBroadcast();

        // 1. Deploy AgentRegistry (owned by creator)
        AgentRegistry registry = new AgentRegistry(deployer);
        console2.log("AgentRegistry deployed at:", address(registry));

        // 2. Deploy AgentEscrow (owned by creator)
        AgentEscrow escrow = new AgentEscrow(deployer);
        console2.log("AgentEscrow deployed at  :", address(escrow));

        vm.stopBroadcast();

        console2.log("\n=== Deployment Successful ===");
        console2.log("Creator (Owner) :", deployer);
        console2.log("AgentRegistry   :", address(registry));
        console2.log("AgentEscrow     :", address(escrow));
        console2.log("==============================");
        console2.log("Save these addresses!");
    }
}
