// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/PepoStablecoin.sol";
// import "../test/MockAggregatorV3.sol";

contract PepoStablecoinScript is Script {
    // MockAggregatorV3 private mockAggregator;

    // function setUp() public {
    //     mockAggregator = new MockAggregatorV3();
    // }

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ethUsd = vm.envAddress("OP_ETH_USD");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        new PepoStablecoin(address(ethUsd));

        vm.stopBroadcast();
    }
}