// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Crowdfund} from "../../src/token/Crowdfund.sol";
import {IDGYM} from "../../src/token/DGYM.sol";

contract SetPrivateSalePhase is Script {
    function run() external {
        vm.startBroadcast();

        address payable crowdfundAddress = payable(
            vm.envAddress("CROWDFUND_ADDRESS")
        );
        Crowdfund crowdfund = Crowdfund(crowdfundAddress);

        IDGYM token = IDGYM(crowdfund.token());
        uint256 totalSupply = token.totalSupply();

        crowdfund.initializePhase(
            "Private sale",
            (0.3 ether * 130) / 100,
            (totalSupply * 7) / 100,
            block.timestamp + 2 weeks,
            block.timestamp + 8 weeks,
            true,
            90 days,
            365 days
        );

        console.log("Private sale phase set");

        vm.stopBroadcast();
    }
}
