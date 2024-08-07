// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Crowdfund} from "../../src/token/Crowdfund.sol";
import {IDGYM} from "../../src/token/DGYM.sol";

contract SetPublicSalePhase is Script {
    function run() external {
        vm.startBroadcast();

        address payable crowdfundAddress = payable(
            vm.envAddress("CROWDFUND_ADDRESS")
        );
        Crowdfund crowdfund = Crowdfund(crowdfundAddress);

        IDGYM token = IDGYM(crowdfund.token());
        uint256 totalSupply = token.totalSupply();

        crowdfund.initializePhase(
            "Public sale",
            (((0.3 ether * 130) / 100) * 130) / 100,
            (totalSupply * 30) / 100,
            block.timestamp + 8 weeks,
            6 weeks,
            true,
            0,
            0
        );

        console.log("Public sale phase set");

        vm.stopBroadcast();
    }
}
