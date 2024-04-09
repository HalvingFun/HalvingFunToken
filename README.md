# Halving Fun (HALVIFU) Token Contract

## Overview
"**Halving Fun**" (Ticker: **HALVIFU**) is an ERC20 token designed to adjust the balance of specific addresses after a predetermined timestamp, simulating the effect of a halving event. Initially minted with a supply of 100 billion tokens, it utilizes OpenZeppelin's ERC20 and Ownable contracts for standard token functionality and ownership management.

This token introduces a unique dynamic to the digital asset's value and supply, reminiscent of cryptocurrency halving mechanisms that traditionally impact mining rewards.

## Features
- **Initial Supply**: 100 billion HALVIFU tokens, minted upon contract deployment to the deployer's address.
- **Halving Mechanism**: Post a specific timestamp, the `balanceOf` function conditionally halves the balance for addresses marked as LP (Liquidity Provider) addresses, simulating a token "halving" event.
- **Ownership Controls**: Utilizing OpenZeppelin's Ownable contract, providing secure management functionalities. After completing all necessary settings and configurations, ownership will be renounced to ensure decentralized governance.

## Contract on BaseScan
View the Halving Fun token contract on BaseScan: (https://basescan.org/address/0xeeaa1Ae7fBE9Be377f3Ec90200871BDeCdA1D66c#code)[https://basescan.org/address/0xeeaa1Ae7fBE9Be377f3Ec90200871BDeCdA1D66c#code]

## Functions
### Public Functions
- `balanceOf(address account)`: Returns the balance of `account`. If the account is an LP address and the current timestamp is past the halving timestamp, this balance is halved.
- `setHalvingTimestamp(uint256 _halvingTimestamp)`: Sets the halving event's timestamp. Only callable by the contract owner.
- `addLPAddress(address _LPaddress)`: Marks an address as an LP address. Only callable by the contract owner.
- `removeLPAddress(address _LPaddress)`: Unmarks an LP address. Only callable by the contract owner.

## Security
This contract inherits security features from OpenZeppelin contracts. However, ensure thorough testing and consider a security audit before production deployment. The decision to renounce ownership after initial configurations further strengthens the contract's trustworthiness by ensuring decentralized control.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
