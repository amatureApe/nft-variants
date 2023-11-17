// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {MyNFT, MyERC20Token, StakingContract} from "../src/Ecosystem1.sol";

contract Ecosystem1Test is Test {
    MyNFT myNFT;
    MyERC20Token myERC20Token;
    StakingContract stakingContract;

    address alice;
    address bob;
    address charlie;

    // The addresses and merkle root
    address[] merkleAddresses = [
        address(0x1111111111111111111111111111111111111111),
        address(0x2222222222222222222222222222222222222222),
        address(0x3333333333333333333333333333333333333333)
    ];
    bytes32 merkleRoot =
        0x4648d35d3cb94e3d7b08fe766ff97724e806128f02504418e7f8d35401969ad9;

    // Example Merkle Proof for address(0x111...)
    bytes32[] exampleProof = [
        bytes32(
            0x761d1673706b12d7996f463b3ee41f89445e41739a7b2688d9e00d8e45cf27f3
        ),
        bytes32(
            0x7f81885cce4ab0d790f926f122f2b9edf96466b883d28e14fd8967ce53f49877
        )
    ];

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        vm.startPrank(bob);

        myNFT = new MyNFT();
        myERC20Token = new MyERC20Token();
        stakingContract = new StakingContract(myNFT, myERC20Token);

        myERC20Token.transfer(
            address(stakingContract),
            10000 * 10 ** myERC20Token.decimals()
        );

        myNFT.setMerkleRoot(merkleRoot);

        vm.stopPrank();
    }

    function test_mint_with_valid_merkle_proof() public {
        vm.prank(merkleAddresses[0]); // Simulate transaction from the first eligible address
        myNFT.mintNFT(exampleProof);

        assertEq(myNFT.balanceOf(merkleAddresses[0]), 1);
    }

    function test_mint_with_invalid_merkle_proof() public {
        vm.expectRevert("Invalid proof");
        vm.prank(address(0x4444444444444444444444444444444444444444)); // An ineligible address
        myNFT.mintNFT(exampleProof); // Using the same proof for a different address
    }

    function test_stake_NFT() public {
        vm.startPrank(merkleAddresses[0]);
        myNFT.mintNFT(exampleProof);
        uint256 tokenId = 1;
        myNFT.approve(address(stakingContract), tokenId);
        stakingContract.stake(tokenId);
        vm.stopPrank();

        assertEq(
            stakingContract.stakers(tokenId),
            merkleAddresses[0],
            "Alice should be the staker"
        );
    }
}
