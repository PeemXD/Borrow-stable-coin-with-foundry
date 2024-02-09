// SPDX-License-Identifier: MIT
// MockAggregatorV3.sol
// This is a simple mock for testing purposes
// In a real environment, you might implement a more sophisticated mock
// or use Hardhat Network features to simulate price feeds.

pragma solidity ^0.8.24;

import "chainlink/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockAggregatorV3 is AggregatorV3Interface {
    int256 private _ethPrice;

    function setEthPrice(int256 ethPrice) external {
        _ethPrice = ethPrice;
    }

    function decimals() external view override returns (uint8) {}

    function description() external view override returns (string memory) {}

    function version() external view override returns (uint256) {}

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {}

    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (0, _ethPrice * 10 ** 8, block.timestamp, 0, 0);
    }
}
