// SPDX-License-Identifier: MIT
// MockAggregatorV3.sol
// This is a simple mock for testing purposes
// In a real environment, you might implement a more sophisticated mock
// or use Hardhat Network features to simulate price feeds.

pragma solidity ^0.8.23;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

contract MockAggregatorV3 is AggregatorV3Interface {
    int256 private _ethPrice;

    function setEthPrice (int256 ethPrice) external {
        _ethPrice = ethPrice;
    }

    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        
        return (0, _ethPrice, block.timestamp, 0, 0);
    }
}