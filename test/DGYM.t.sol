// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeGymToken} from "../src/token/DGYM.sol";
import {MockAuthority} from "./MockAuthority.sol";

contract DeGymTokenTest is Test {
    DeGymToken private token;
    MockAuthority private authority;
    address private owner = address(0x123);
    address private user = address(0x456);

    function setUp() public {
        authority = new MockAuthority();
        token = new DeGymToken(1000 ether, 2000 ether);
        authority.setManager(owner, true);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.cap(), 2000 ether);
    }

    function testMint() public {
        vm.startPrank(owner);
        token.mint(owner, 500 ether);
        assertEq(token.totalSupply(), 1500 ether);
        vm.stopPrank();
    }

    function testMintExceedsCap() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20Capped: cap exceeded");
        token.mint(owner, 1501 ether);
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(owner);
        token.burn(500 ether);
        assertEq(token.totalSupply(), 500 ether);
        vm.stopPrank();
    }

    function testSetCap() public {
        vm.startPrank(owner);
        token.setCap(3000);
        assertEq(token.cap(), 3000 ether);
        vm.stopPrank();
    }

    function testSetCapLowerThanTotalSupply() public {
        vm.startPrank(owner);
        vm.expectRevert(
            "New cap must be greater than or equal to total supply"
        );
        token.setCap(900);
        vm.stopPrank();
    }
}
