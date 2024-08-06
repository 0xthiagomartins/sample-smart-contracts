// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/token/DGYM.sol";

contract DeployDeGymToken is Script {
    function run() external {
        vm.startBroadcast();

        uint256 initialSupply = 1000 ether;
        uint256 initialCap = 2000 ether;

        DeGymToken token = new DeGymToken(initialSupply, initialCap);

        console.log("DeGymToken deployed at:", address(token));

        vm.stopBroadcast();
    }
}
