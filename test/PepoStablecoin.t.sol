// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "../lib/forge-std/src/Test.sol";
import "forge-std/Test.sol";
import "../src/PepoStablecoin.sol";
import "./MockAggregatorV3.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract PepoStablecoinTest is Test {
    PepoStablecoin private pepoStablecoin;
    MockAggregatorV3 private mockAggregator;

    // error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        mockAggregator = new MockAggregatorV3();
        pepoStablecoin = new PepoStablecoin(address(mockAggregator));
    }

    function test_BorrowWith50PercentRatio() public payable {
        uint256 ratio = 50;
        uint256 collateralAmount = 1 ether;
        int256 ethPrice = 2000;

        mockAggregator.setEthPrice(ethPrice);
        pepoStablecoin.borrow{value: collateralAmount}(ratio);
        uint256 actualDebt = pepoStablecoin.getDebt(address(this));

        uint256 expectedDebt = 1000;
        assertEq(expectedDebt, actualDebt, "Debt does not match");
    }

    function test_BorrowWith75PercentRatio() public payable {
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

    function test_RevertWhen_BorrowingWithInvalidRatio() public payable {
        uint256 invalidRatio = 76;

        vm.expectRevert("ratio must less than equal 75%");
        pepoStablecoin.borrow{value: 1 ether}(invalidRatio);
    }

    function test_RevertWhen_NotOwnerCallLiquidate() public payable {
        // arrange
        uint256 ratio = 50;
        uint256 collateralAmount = 1 ether;
        int256 ethPrice = 2000;
        int256 newEthPrice = 1000;
        address borrowerAccount = vm.addr(1);
        address notOwnerAccount = vm.addr(2);
        mockAggregator.setEthPrice(ethPrice);
        pepoStablecoin.borrow{value: collateralAmount}(ratio);
        mockAggregator.setEthPrice(newEthPrice);

        // act & assert
        bytes memory ownableUnauthorizedAccount =
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwnerAccount);
        vm.expectRevert(ownableUnauthorizedAccount);
        vm.prank(notOwnerAccount);
        pepoStablecoin.liquidate(borrowerAccount);
    }
}
