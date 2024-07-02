// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/Deploy.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address user = makeAddr("user");
    uint256 constant startingBalance = 1 ether;
    uint256 constant amount = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(user, startingBalance);
    }

    function testMinFive() public view {
        assertEq(fundMe.getMin(), 5e18);
    }

    function testOwner() public view {
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFund() public {
        fundMe.fund{value: 5e18}();
        assertEq(fundMe.getLog(address(this)), 5e18);
        // console.log(fundMe.log(address(this)));
    }

    function testReverts() public {
        vm.expectRevert();
        fundMe.fund{value: 1e15}();
    }

    function testToUpdateLog() public {
        vm.prank(user);
        fundMe.fund{value: amount}();

        uint256 amountFunded = fundMe.getLog(user);
        assertEq(amountFunded, amount);
    }

    function testToUpdateFunders() public {
        vm.prank(user);
        fundMe.fund{value: amount}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, user);
    }

    modifier funded() {
        vm.prank(user);
        fundMe.fund{value: amount}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(user);
        fundMe.fund{value: amount}();

        vm.prank(user);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawSingle() public funded {
        // Arrange
        uint256 balanceBefore = fundMe.getOwner().balance;
        uint256 contractBalance = address(fundMe).balance;

        // Act
        uint256 startGas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endGas = gasleft();
        uint256 gasUsed = (startGas - endGas) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        // Assert
        uint256 balanceAfter = fundMe.getOwner().balance;
        uint256 contractBalanceAfter = address(fundMe).balance;
        assertEq(contractBalanceAfter, 0);
        assertEq(balanceBefore + contractBalance, balanceAfter);
    }

    function testWithdrawMultiple() public funded {
        // Arrange
        uint160 funders = 10;
        for (uint160 i = 2; i < funders; i++) {
            hoax(address(i), amount);
            fundMe.fund{value: amount}();
        }

        uint256 balanceBefore = fundMe.getOwner().balance;
        uint256 contractBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 balanceAfter = fundMe.getOwner().balance;
        assertEq(address(fundMe).balance, 0);
        assertEq(balanceBefore + contractBalance, balanceAfter);
    }

    function testWithdrawMultipleCheap() public funded {
        // Arrange
        uint160 funders = 10;
        for (uint160 i = 2; i < funders; i++) {
            hoax(address(i), amount);
            fundMe.fund{value: amount}();
        }

        uint256 balanceBefore = fundMe.getOwner().balance;
        uint256 contractBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        uint256 balanceAfter = fundMe.getOwner().balance;
        assertEq(address(fundMe).balance, 0);
        assertEq(balanceBefore + contractBalance, balanceAfter);
    }
}
