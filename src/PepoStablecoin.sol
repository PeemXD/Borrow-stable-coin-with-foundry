// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../test/MockAggregatorV3.sol";

contract PepoStablecoin is ERC20, ERC20Permit, Ownable{
    struct DebtCollateralRatio {
        uint debt;
        uint collateral;
    }
    mapping(address => DebtCollateralRatio) debtCollateralRatios;
    AggregatorV3Interface internal ethPriceFeed;

    event Borrow(address indexed owner, uint amount, bool isUSDP);
    event PayBack(address indexed owner, uint debtAmount, bool isUSDP);
    event ReturnCollateralAssets(address indexed owner, uint value, bool isETH);
    event Liquidate(address indexed owner, uint amount, bool isETH);



    constructor(address ethUsd) ERC20("Pepo Stablecoin", "USDP") ERC20Permit("USDP") Ownable(_msgSender()) {
        // Use MockAggregatorV3 for local development
        // ethPriceFeed = AggregatorV3Interface(address(new MockAggregatorV3()));
        ethPriceFeed = AggregatorV3Interface(ethUsd);
        // Use Real in ETH chain
        // ethPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function getEthPrice() public view returns (uint) {
        (, int price, , ,) = ethPriceFeed.latestRoundData();
        return uint(price);
    }

    function borrow(uint ratio) public payable {
        require(ratio <= 75, "ratio must less than equal 75%");

        uint collateral =  msg.value;
        uint debt = collateral / 10**18 * getEthPrice() * ratio / 100;
        debtCollateralRatios[msg.sender] = DebtCollateralRatio(
            debt,
            collateral
        );

        _mint(_msgSender(), debt);

        emit Borrow(_msgSender(), debt, true);
    }

    function payBack(uint256 payBackAmount) public onlyOwner {
        require(payBackAmount <= debtCollateralRatios[_msgSender()].debt, 
        "the payBack amount must less than equal your dept");

        _burn(_msgSender(), payBackAmount);
        debtCollateralRatios[_msgSender()].debt = debtCollateralRatios[_msgSender()].debt - payBackAmount;

        emit PayBack(_msgSender(), payBackAmount, true);

        if (debtCollateralRatios[_msgSender()].debt == 0) {
            uint collateralAsset = debtCollateralRatios[_msgSender()].collateral;
            payable(_msgSender()).transfer(collateralAsset);
            debtCollateralRatios[_msgSender()].collateral = 0;
            
            emit ReturnCollateralAssets(_msgSender(), collateralAsset, true);
        }        
    }

    function liquidate(address addr) public onlyOwner {
        require(
            (debtCollateralRatios[addr].debt * 100) / 
            (debtCollateralRatios[addr].collateral * getEthPrice())  >= 85, 
            "currently dept to correteral ratio less than 85%");

        // TODO: sell ETH
        // ...
        
        uint liquidateEthAmount = debtCollateralRatios[addr].collateral;
        debtCollateralRatios[addr] = DebtCollateralRatio(0, 0);

        emit Borrow(addr, liquidateEthAmount, true);
    }

    function getDebt(address addr) public view returns (uint debt) {
        return debtCollateralRatios[addr].debt;
    }

    function getCollateral(address addr) public view returns (uint collateral) {
        return debtCollateralRatios[addr].collateral / 10**18 * getEthPrice();
    }

    function getRatio(address addr) public view returns (uint ratio) {
        return (debtCollateralRatios[addr].debt * 100) / 
        (debtCollateralRatios[addr].collateral / 10**18 * 
        getEthPrice());
    }
    
}