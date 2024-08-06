// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/token/Crowdfund.sol";
import "../src/token/DGYM.sol";

contract InteractCrowdfund is Script {
    function run() external {
        vm.startBroadcast();

        Crowdfund crowdsale = Crowdfund(0xYourDeployedCrowdfundAddress); // Replace with the actual deployed Crowdfund address

        // Interactions
        address phaseName = "Phase1";
        uint256 rate = 1000;
        uint256 allocation = 100 ether;
        uint256 startTime = block.timestamp + 1 hours;
        uint256 endTime = block.timestamp + 1 days;
        bool burnable = true;

        crowdsale.setPhase(phaseName, rate, allocation, startTime, endTime, burnable);
        console.log("Phase set");

        crowdsale.activatePhase(phaseName);
        console.log("Phase activated");

        vm.stopBroadcast();
    }
}
