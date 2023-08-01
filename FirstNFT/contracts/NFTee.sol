// SPDX-License-Identifier: MIT

//Telling Ethereum which Solidity version to use
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Contract 'NFTee' _IS_ an ERC721
contract NFTee is ERC721 {
    // Create an ERC721 contract
    // Mint some NFTs for myself

    constructor() ERC721("LearnWeb3NFT", "LNFT") {
        // Mint 1 NFT for myself
        _mint(msg.sender, 1);
        _mint(msg.sender, 2);
        _mint(msg.sender, 3);
        _mint(msg.sender, 4);
        _mint(msg.sender, 5);
    }
}
