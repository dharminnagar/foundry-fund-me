-include .env

build:
	forge build

deploy-sepolia:
	forge script script/Deploy.s.sol:DeployFundMe --rpc-url $(SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv