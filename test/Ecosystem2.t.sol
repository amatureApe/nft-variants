// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MyCollection, PrimeTokenCounter} from "../src/Ecosystem2.sol";

contract CounterTest is Test {
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
        counter = new PrimeTokenCounter();
    }

    function test_mint() public {
        vm.prank(bob);
        collection.mint(bob, 0);
        assertEq(collection.balanceOf(bob), 1);
    }
}
