// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Fund
// Withdraw

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundContract is Script {
    uint256 constant sendValue = 0.01 ether;
    function fundcontract(address recent) public {
        vm.startBroadcast();
        FundMe(payable(recent)).fund{value: sendValue}();
        vm.stopBroadcast();
        console.log("Funded contract with amount: %s", sendValue);
    }

    function run() external {
        address recent = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundcontract(recent);
    }
}

contract WithdrawContract is Script {
    uint256 constant sendValue = 0.01 ether;
    function withdrawContract(address recent) public {
        vm.startBroadcast();
        FundMe(payable(recent)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address recent = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawContract(recent);
    }
}
