// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title HalvingFun ERC20 Token
/// @dev Extends ERC20 Token Standard with Voting Capabilities and includes a mechanism for halving rewards based on past votes.
contract HalvingFun is ERC20, ERC20Votes, Ownable, ReentrancyGuard {
    /// Block number at which the next halving event is scheduled.
    uint256 public halvingBlockNumber;

    /// Mapping to track whether an address has already claimed its halving reward.
    mapping(address => bool) public hasReceivedHalvingReward;

    /// Initial supply of tokens, set to 100 billion tokens (with 18 decimal places).
    uint256 constant initialSupply = 1e11 * 1e18;

    /// Constructs the ERC20 token with a name, symbol, mints the initial supply to the deployer, and initializes the halving block number.
    constructor() ERC20("Halving Fun", "$HALVIFU") ERC20Permit("Halving Fun") {
        _mint(msg.sender, initialSupply);
        halvingBlockNumber = 13396614;
    }

    /// @notice Allows users to claim their halving reward based on their balance at the halving event.
    function claimMyReward() public nonReentrant {
        require(
            !hasReceivedHalvingReward[msg.sender],
            "Reward already claimed"
        );
        address[] memory accounts = new address[](1);
        accounts[0] = msg.sender;
        _mintHalvingReward(accounts);
    }

    /// @notice Allows the owner to mint rewards for a list of addresses based on their balances at the halving event.
    /// @param accounts Array of addresses to mint rewards for.
    function spreadRewardsForAddresses(
        address[] memory accounts
    ) public onlyOwner nonReentrant {
        _mintHalvingReward(accounts);
    }

    /// @notice Sets a new block number for the halving event.
    /// @dev Can only be called by the contract owner, and the block number must be in the future.
    /// @param _halvingBlockNumber The future block number for the next halving event.
    function setHalvingBlockNumber(
        uint256 _halvingBlockNumber
    ) public onlyOwner {
        require(
            _halvingBlockNumber > block.number,
            "Halving block number must be in the future."
        );
        halvingBlockNumber = _halvingBlockNumber;
    }

    /// @notice Calculates the potential reward for a given account based on its balance at the halving event.
    /// @dev Returns 0 if the reward has already been claimed for the account.
    /// @param account The address of the account to calculate the reward for.
    /// @return The calculated reward amount based on the account's past votes at the halving block number, or 0 if already claimed.
    function calculateReward(address account) public view returns (uint256) {
        if (
            block.number < halvingBlockNumber ||
            hasReceivedHalvingReward[account]
        ) {
            return 0;
        }
        uint256 accountBalanceAtHalving = getPastVotes(
            account,
            halvingBlockNumber
        );
        return accountBalanceAtHalving; // Return the account balance at halving as the reward amount.
    }

    // Private function to mint halving rewards for a list of accounts based on the halving block number.
    function _mintHalvingReward(address[] memory accounts) private {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!hasReceivedHalvingReward[accounts[i]]) {
                uint256 accountBalanceAtHalving = getPastVotes(
                    accounts[i],
                    halvingBlockNumber
                );
                hasReceivedHalvingReward[accounts[i]] = true;
                _mint(accounts[i], accountBalanceAtHalving);
            }
        }
    }

    // Overrides required by Solidity for ERC20 and ERC20Votes integration.
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        if (balanceOf(to) == 0 && delegates(to) == address(0))
            _delegate(to, to);
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
