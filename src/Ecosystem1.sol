// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MyNFT is ERC721, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public totalSupply;
    bytes32 public merkleRoot; // Merkle root for the discount eligibility
    BitMaps.BitMap private minted; // Bitmap to track if an address has minted

    // Royalty info
    address payable public royaltyRecipient;
    uint256 public constant royaltyPercentage = 250; // 2.5%

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {
        totalSupply = 0;
    }

    function mintNFT(bytes32[] calldata _merkleProof) external {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalid proof"
        );

        // Check if the address has already minted using the bitmap
        require(
            !minted.get(uint256(uint160(msg.sender))),
            "Address has already minted"
        );

        _mint(msg.sender, totalSupply + 1);
        totalSupply++;

        // Set the bitmap for the address to indicate minting
        minted.set(uint256(uint160(msg.sender)));
    }

    // Royalty function
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address, uint256) {
        uint256 royaltyAmount = (_salePrice * royaltyPercentage) / 10000;
        return (royaltyRecipient, royaltyAmount);
    }

    // Function to set merkleRoot
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    // Function to set royalty recipient
    function setRoyaltyRecipient(address payable _recipient) public onlyOwner {
        royaltyRecipient = _recipient;
    }
}

contract MyERC20Token is ERC20, Ownable2Step {
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}

contract StakingContract is IERC721Receiver {
    MyNFT public nft;
    MyERC20Token public erc20;

    mapping(uint256 => address) public stakers;
    mapping(uint256 => uint256) public stakingTimestamps;

    constructor(MyNFT _nft, MyERC20Token _erc20) {
        nft = _nft;
        erc20 = _erc20;
    }

    function stake(uint256 tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        stakers[tokenId] = msg.sender;
        stakingTimestamps[tokenId] = block.timestamp;
    }

    function withdraw(uint256 tokenId) external {
        require(stakers[tokenId] == msg.sender, "Not staker");
        require(
            block.timestamp - stakingTimestamps[tokenId] >= 1 days,
            "Cannot withdraw yet"
        );

        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        erc20.transfer(msg.sender, 10 * (10 ** uint256(erc20.decimals())));

        stakingTimestamps[tokenId] = 0;
        stakers[tokenId] = address(0);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
