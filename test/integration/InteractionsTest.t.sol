// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/Deploy.s.sol";
import {FundContract, WithdrawContract} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address user = makeAddr("user");
    uint256 constant startingBalance = 1 ether;
    uint256 constant amount = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(user, startingBalance);
    }

    function testWithdraw() public {
        FundContract fund = new FundContract();
        fund.fundcontract(address(fundMe));

        WithdrawContract withdraw = new WithdrawContract();
        withdraw.withdrawContract(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
