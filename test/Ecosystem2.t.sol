// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {MyCollection, PrimeTokenCounter} from "../src/Ecosystem2.sol";

contract Ecosystem2Test is Test {
    MyCollection public collection;
    PrimeTokenCounter public counter;

    address alice;
    address bob;
    address charlie;

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        collection = new MyCollection();
        counter = new PrimeTokenCounter(address(collection));
    }

    function test_mint() public {
        vm.prank(bob);
        collection.mint(bob, 1);
        assertEq(collection.balanceOf(bob), 1);

        vm.prank(alice);
        collection.mint(bob, 2);
        assertEq(collection.balanceOf(bob), 2);
    }

    function testFail_mint_out_of_bounds() public {
        vm.prank(bob);
        collection.mint(bob, 101);
    }

    function test_check_prime_numbers() public {
        vm.startPrank(alice);
        collection.mint(bob, 17);
        collection.mint(bob, 4);
        assertEq(counter.countPrimeTokens(bob), 1);

        collection.mint(bob, 53);
        assertEq(counter.countPrimeTokens(bob), 2);
    }
}
