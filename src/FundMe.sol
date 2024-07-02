// Get Funds from the user
// Withdraw funds
// Set minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address funder => uint256 amount) private log;
    address[] private funders;

    address private immutable owner;
    uint256 private constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private priceFeed;

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "didn't send enough ETH"
        );
        funders.push(msg.sender);
        log[msg.sender] += msg.value;
    }

    constructor(address s_priceFeed) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(s_priceFeed);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    modifier admin() {
        require(msg.sender == owner, "Must be owner!");
        _;
    }

    function withdraw() public admin {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            log[funder] = 0;
        }

        funders = new address[](0);

        // 3 Ways to withdraw ETH from contract
        // transfer()
        // payable(msg.sender).transfer(address(this).balance);

        // // send()
        // bool status = payable(msg.sender).send(address(this).balance);
        // require(status, "Money Transfer failed!");

        // call()
        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Call failed!");
    }

    function cheaperWithdraw() public admin {
        uint256 lengthOfFunders = funders.length;
        for (uint256 i = 0; i < lengthOfFunders; i++) {
            address funder = funders[i];
            log[funder] = 0;
        }

        funders = new address[](0);

        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Call failed!");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // Getters
    function getLog(address funder) external view returns (uint256) {
        return log[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return funders[index];
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getMin() external pure returns (uint256) {
        return MINIMUM_USD;
    }
}
