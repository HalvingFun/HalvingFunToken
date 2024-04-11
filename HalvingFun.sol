// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/security/ReentrancyGuard.sol";

/// @title HalvingFun ERC20 Token
/// @dev Extends ERC20 Token Standard with Voting Capabilities and includes a mechanism for halving rewards based on past votes.
contract HalvingFun is ERC20, ERC20Votes, Ownable, ReentrancyGuard {
    uint256 public halvingBlockNumber;
    uint256 public snapshotBlock;
    mapping(address => bool) public hasReceivedHalvingReward;
    uint256 constant initialSupply = 1e11 * 1e18; // 100 billion tokens with 18 decimal places

    event SnapshotBlockSet(uint256 snapshotBlock);

    constructor() ERC20("Halving Fun", "$HALVIFU") ERC20Permit("Halving Fun") {
        _mint(msg.sender, initialSupply);
        halvingBlockNumber = 13396614;
    }

    function setRandomSnapshotBlock() public {
        require(snapshotBlock == 0, "Can only be setted once");

        uint256 startBlock = halvingBlockNumber - 172800;

        require(
            block.number > halvingBlockNumber,
            "Can only set snapshot before the start range."
        );

        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    block.coinbase
                )
            )
        );
        uint256 range = halvingBlockNumber - startBlock;
        uint256 randomOffset = seed % range;
        snapshotBlock = startBlock + randomOffset;

        emit SnapshotBlockSet(snapshotBlock);
    }

    function claimMyReward() public nonReentrant {
        require(
            block.number > halvingBlockNumber,
            "Halving has not yet occurred."
        );
        require(
            !hasReceivedHalvingReward[msg.sender],
            "Reward already claimed"
        );
        require(snapshotBlock != 0, "Snapshot block not set.");

        // Ensuring that the claim is after the snapshot for the reward calculation.
        require(block.number > halvingBlockNumber, "Claim period not started.");

        uint256 rewardAmount = calculateReward(msg.sender);
        hasReceivedHalvingReward[msg.sender] = true;
        _mint(msg.sender, rewardAmount);
    }

    function calculateReward(address account) public view returns (uint256) {
        if (hasReceivedHalvingReward[account] || snapshotBlock == 0) {
            return 0;
        }
        uint256 accountBalanceAtSnapshot = getPastVotes(account, snapshotBlock);
        // Simple reward formula; adjust as needed
        return accountBalanceAtSnapshot;
    }

    // Overrides required by Solidity for ERC20 and ERC20Votes integration.
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        if (balanceOf(to) == 0 && delegates(to) == address(0))
            _delegate(to, to);
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
