// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Crowdfund} from "../src/token/Crowdfund.sol";
import {DeGymToken} from "../src/token/DGYM.sol";
import {MockAuthority} from "./MockAuthority.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDGYM} from "../src/token/DGYM.sol";
import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";

contract CrowdfundTest is Test {
    Crowdfund private crowdsale;
    DeGymToken private token;
    MockAuthority private authority;
    address private owner = address(0x123);
    address private wallet = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        token = new DeGymToken();
        authority = new MockAuthority();
        crowdsale = new Crowdfund(address(token), wallet, address(authority));
        authority.setManager(owner, true);

        // Initialize the three phases
        uint256 totalSupply = token.totalSupply();

        crowdsale.initializePhase(
            "Pre-seed sale",
            0.3 ether,
            (totalSupply * 3) / 100,
            block.timestamp,
            30 days,
            true,
            60 days,
            365 days
        );
        crowdsale.initializePhase(
            "Private sale",
            (0.3 ether * 130) / 100,
            (totalSupply * 7) / 100,
            block.timestamp + 2 weeks,
            6 weeks,
            true,
            90 days,
            365 days
        );
        crowdsale.initializePhase(
            "Public sale",
            (((0.3 ether * 130) / 100) * 130) / 100,
            (totalSupply * 30) / 100,
            block.timestamp + 8 weeks,
            6 weeks,
            true,
            0,
            0
        );

        // Allocate tokens to the crowdsale contract
        token.mint(address(crowdsale), (totalSupply * 50) / 100); // 50% of total supply
        vm.stopPrank();
    }

    function testInitialization() public {
        uint256 totalSupply = token.totalSupply();

        // Check initial phase settings for Pre-seed sale
        (
            uint256 rate,
            uint256 allocation,
            uint256 sold,
            bool burnable,
            uint256 startTime,
            uint256 endTime,
            bool active,
            uint64 cliffDuration,
            uint64 vestingDuration
        ) = crowdsale.phases("Pre-seed sale");
        assertEq(rate, 0.3 ether);
        assertEq(allocation, (totalSupply * 3) / 100);
        assertEq(sold, 0);
        assertEq(burnable, true);
        assertEq(cliffDuration, 60 days);
        assertEq(vestingDuration, 365 days);

        // Check initial phase settings for Private sale
        (
            rate,
            allocation,
            sold,
            burnable,
            startTime,
            endTime,
            active,
            cliffDuration,
            vestingDuration
        ) = crowdsale.phases("Private sale");
        assertEq(rate, (0.3 ether * 130) / 100);
        assertEq(allocation, (totalSupply * 7) / 100);
        assertEq(sold, 0);
        assertEq(burnable, true);
        assertEq(cliffDuration, 90 days);
        assertEq(vestingDuration, 365 days);

        // Check initial phase settings for Public sale
        (
            rate,
            allocation,
            sold,
            burnable,
            startTime,
            endTime,
            active,
            cliffDuration,
            vestingDuration
        ) = crowdsale.phases("Public sale");
        assertEq(rate, (((0.3 ether * 130) / 100) * 130) / 100);
        assertEq(allocation, (totalSupply * 30) / 100);
        assertEq(sold, 0);
        assertEq(burnable, true);
        assertEq(cliffDuration, 0);
        assertEq(vestingDuration, 0);
    }
}
