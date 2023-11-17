// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyNFTCollection is ERC721Enumerable {
    constructor() ERC721("MyNFTCollection", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        require(
            tokenId > 0 && tokenId <= 100,
            "Token ID must be between 1 and 100"
        );
        _mint(to, tokenId);
    }
}

contract PrimeTokenCounter {
    MyNFTCollection nftCollection;

    constructor(address nftCollectionAddress) {
        nftCollection = MyNFTCollection(nftCollectionAddress);
    }

    function isPrime(uint256 number) public pure returns (bool) {
        if (number < 2) return false;
        for (uint256 i = 2; i * i <= number; i++) {
            if (number % i == 0) return false;
        }
        return true;
    }

    function countPrimeTokens(address owner) public view returns (uint256) {
        uint256 count = 0;
        uint256 balance = nftCollection.balanceOf(owner);
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = nftCollection.tokenOfOwnerByIndex(owner, i);
            if (isPrime(tokenId)) {
                count++;
            }
        }
        return count;
    }
}
