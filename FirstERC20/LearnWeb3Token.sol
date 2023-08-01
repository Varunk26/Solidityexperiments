// SPDX-License-Identifier: MIT
// What version of solidity do I want to use
// ^0.8.0 any version from 0.8.x
pragma solidity ^0.8.0;

// Import ERC20 from open-zeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract LearnWeb3Token is ERC20 {

    // We also want to call constructor from ERC 20
    constructor (string memory _name, string memory _symbol) 
    ERC20(_name, _symbol) 
    {
        // Get some tokens
        // msg.sender is the person deploying the contract
        _mint(msg.sender, 1000 * (10 ** 18));
        // This is our contract
    }
}
