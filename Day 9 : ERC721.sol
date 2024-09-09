// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 public tokenCounter;

    constructor() ERC721("MyNFT", "NFT") {
        tokenCounter = 0;
    }

    function mintNFT(address recipient) public {
        _safeMint(recipient, tokenCounter);
        tokenCounter++;
    }
}
