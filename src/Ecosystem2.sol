// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyCollection is ERC721Enumerable {
    mapping(uint256 => bool) private _isPrime;

    error TokenIdOutOfRange();
    error TokenIdDoesNotExist();

    constructor() ERC721("MyCollection", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        if (tokenId <= 0 || tokenId > 100) {
            revert TokenIdOutOfRange();
        }
        _mint(to, tokenId);
        _isPrime[tokenId] = _checkPrime(tokenId);
    }

    function isPrime(uint256 tokenId) public view returns (bool) {
        if (ownerOf(tokenId) == address(0)) {
            revert TokenIdDoesNotExist();
        }
        return _isPrime[tokenId];
    }

    function _checkPrime(uint256 number) private pure returns (bool) {
        if (number == 2) return true;
        if (number < 2 || number % 2 == 0) return false;
        for (uint256 i = 3; i * i <= number; i += 2) {
            if (number % i == 0) return false;
        }
        return true;
    }
}

contract PrimeTokenCounter {
    MyCollection collection;

    constructor(address collectionAddress) {
        collection = MyCollection(collectionAddress);
    }

    function countPrimeTokens(address owner) public view returns (uint256) {
        uint256 count = 0;
        uint256 balance = collection.balanceOf(owner);
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = collection.tokenOfOwnerByIndex(owner, i);
            if (collection.isPrime(tokenId)) {
                count++;
            }
        }
        return count;
    }
}
