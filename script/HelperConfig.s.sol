// SPDX-License-Identifier: MIT

// Deploy mocks when we are on a local anvil chain
// Keep track of contract address across different chains
// Sepolia ETH/USD price feed
// Mainnet ETH/USD price feed

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetwork;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetwork = getSepolia();
        } else if (block.chainid == 1) {
            activeNetwork = getMainnet();
        } else {
            activeNetwork = getAnvil();
        }
    }

    function getSepolia() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnet() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getAnvil() public returns (NetworkConfig memory) {
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }

        vm.startBroadcast();
        MockV3Aggregator priceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(priceFeed)
        });
        return anvilConfig;
    }
}
