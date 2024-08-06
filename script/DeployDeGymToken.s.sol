// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {DeGymToken} from "../src/token/DGYM.sol";

contract DeployDeGymToken is Script {
    function run() external {
        vm.startBroadcast();

        DeGymToken token = new DeGymToken();

        console.log("DeGymToken deployed at:", address(token));

        vm.stopBroadcast();
    }
}
