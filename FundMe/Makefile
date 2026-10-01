-include .env

.PHONY: build deploy 


build:
	 @forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

deploy:
	forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)
NETWORK_ARGS := --rpc-url $(DEFAULT_ANVIL) --private-key $(PRIVATE_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
else
NETWORK_ARGS := --rpc-url $(DEFAULT_ANVIL) --private-key $(PRIVATE_KEY) --broadcast
endif