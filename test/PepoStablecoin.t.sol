// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "../lib/forge-std/src/Test.sol";
import "forge-std/Test.sol";
import "../src/PepoStablecoin.sol";
import "./MockAggregatorV3.sol";

contract PepoStablecoinTest is Test {

    PepoStablecoin private pepoStablecoin;
    MockAggregatorV3 private mockAggregator;

    function setUp() public {
        mockAggregator = new MockAggregatorV3();
        pepoStablecoin = new PepoStablecoin(address(mockAggregator));
    }

    function testBorrowWith50PercentRatio() public payable {
        uint256 ratio = 50;
        uint256 collateralAmount = 1 ether;
        int256 ethPrice = 2000;
        mockAggregator.setEthPrice(ethPrice);

        pepoStablecoin.borrow{value: collateralAmount}(ratio);
        uint256 actualDebt = pepoStablecoin.getDebt(address(this));

        uint expectedDebt = 1000;
        assertEq(expectedDebt, actualDebt, "Debt does not match");
    }

    function testBorrowWith75PercentRatio() public payable {
        uint256 ratio = 75;
        uint256 collateralAmount = 1 ether;
        int256 ethPrice = 2234;
        address borrower = vm.addr(1);
        vm.deal(borrower, 1 ether);
        mockAggregator.setEthPrice(ethPrice);
        
        vm.startPrank(borrower);
        pepoStablecoin.borrow{value: collateralAmount}(ratio);
        uint256 actualDebt = pepoStablecoin.getDebt(borrower);
        vm.stopPrank();
        
        uint256 expectedDebt = 1675;
        assertEq(expectedDebt, actualDebt, "Debt does not match");
    }

    function testRevertWhenBorrowingWithInvalidRatio() public payable {
        uint256 invalidRatio = 76;
        
        vm.expectRevert("ratio must less than equal 75%");
        pepoStablecoin.borrow{value: 1 ether}(invalidRatio);
    }
}
