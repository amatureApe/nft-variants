import { ethers } from 'ethers';
import { MerkleTree } from 'merkletreejs';

function generateMerkleTree(addresses) {
    // Create leaf nodes
    const leafNodes = addresses.map(addr => ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address"], [addr])));

    // Create Merkle Tree
    const merkleTree = new MerkleTree(leafNodes, ethers.utils.keccak256, { sortPairs: true });

    return merkleTree;
}

function generateMerkleProof(merkleTree, address) {
    const leaf = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address"], [address]));
    return {
        proof: merkleTree.getHexProof(leaf),
        leaf
    };
}

const merkleAddresses = [
    '0x1111111111111111111111111111111111111111',
    '0x2222222222222222222222222222222222222222',
    '0x3333333333333333333333333333333333333333',
];

// Generate Merkle Tree
const merkleTree = generateMerkleTree(merkleAddresses);

// Get Merkle Root
const merkleRoot = merkleTree.getHexRoot();
console.log('Merkle Root:', merkleRoot);

// Generate and Display Merkle Proofs and Leaves for Each Address
merkleAddresses.forEach(address => {
    const { proof, leaf } = generateMerkleProof(merkleTree, address);
    console.log(`Merkle Proof for ${address}:`, proof);
    console.log(`Merkle Leaf for ${address}:`, leaf);
});



////////////////////// Generated proofs ////////////////////////////////
/*
Merkle Root: 0x4648d35d3cb94e3d7b08fe766ff97724e806128f02504418e7f8d35401969ad9
Merkle Proof for 0x1111111111111111111111111111111111111111: [
  '0x761d1673706b12d7996f463b3ee41f89445e41739a7b2688d9e00d8e45cf27f3',
  '0x7f81885cce4ab0d790f926f122f2b9edf96466b883d28e14fd8967ce53f49877'
]
Merkle Proof for 0x2222222222222222222222222222222222222222: [
  '0xaafae41182fdefb0af836c3b506e127c7f229f33360c66de1139f4b0316f09d8',
  '0x7f81885cce4ab0d790f926f122f2b9edf96466b883d28e14fd8967ce53f49877'
]
Merkle Proof for 0x3333333333333333333333333333333333333333: [
  '0x6a486616bc86091cacdd17307700bf13d1d2c65a67fec41bccab081f8f7b4fb2'
]
*/