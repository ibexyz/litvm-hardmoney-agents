// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {AgentEscrow} from "contracts/src/core/AgentEscrow.sol";
import {AgentRegistry} from "contracts/src/core/AgentRegistry.sol";

/**
 * @title Deploy
 * @notice Deploys core Hard Money Agent contracts to LitVM LiteForge
 *
 * Creator / Owner address:
 * 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10
 *
 * IMPORTANT:
 * Run this script using the private key of the address above
 * so that the deployer becomes the owner of both contracts.
 *
 * Fixes applied vs. the original file:
 *  1. Import paths corrected to be relative to the repo root
 *     (Deploy.s.sol lives at the repo root, not inside a script/
 *     folder, and foundry.toml sets `src = "contracts/src"`).
 *  2. The deployer address is now derived from PRIVATE_KEY via
 *     vm.addr(), instead of reading msg.sender before broadcast
 *     starts. Reading msg.sender at that point returns Foundry's
 *     default script sender, NOT the address matching
 *     --private-key, so the original require() would always
 *     revert.
 *  3. vm.startBroadcast(deployerPrivateKey) is called with the
 *     explicit key so the broadcaster matches `deployer`.
 */
contract Deploy is Script {
    // Expected creator address (for verification)
    address constant EXPECTED_CREATOR = 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("========================================");
        console2.log("LitVM Hard Money Agents - Deployment");
        console2.log("========================================");
        console2.log("Deployer / Creator :", deployer);
        console2.log("Expected Creator :", EXPECTED_CREATOR);
        console2.log("Chain ID :", block.chainid);
        console2.log("========================================");

        require(deployer == EXPECTED_CREATOR, "Wrong deployer wallet! Use the correct private key.");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy AgentRegistry (owned by creator)
        AgentRegistry registry = new AgentRegistry(deployer);
        console2.log("AgentRegistry deployed at:", address(registry));

        // 2. Deploy AgentEscrow (owned by creator)
        AgentEscrow escrow = new AgentEscrow(deployer);
        console2.log("AgentEscrow deployed at :", address(escrow));

        vm.stopBroadcast();

        console2.log("\n=== Deployment Successful ===");
        console2.log("Creator (Owner) :", deployer);
        console2.log("AgentRegistry :", address(registry));
        console2.log("AgentEscrow :", address(escrow));
        console2.log("==============================");
        console2.log("Save these addresses!");
    }
}
