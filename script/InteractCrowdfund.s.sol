// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Crowdfund} from "../src/token/Crowdfund.sol";

contract InteractCrowdfund is Script {
    function run() external {
        address payable crowdsaleAddress = payable(
            vm.envAddress("CROWDSALE_ADDRESS")
        );

        vm.startBroadcast();

        Crowdfund crowdsale = Crowdfund(crowdsaleAddress);

        // Activate phases
        crowdsale.activatePhase("Pre-seed sale");
        console.log("Pre-seed sale activated");

        crowdsale.activatePhase("Private sale");
        console.log("Private sale activated");

        crowdsale.activatePhase("Public sale");
        console.log("Public sale activated");

        vm.stopBroadcast();
    }
}
