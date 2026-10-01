
DEFAULT_ANVIL_PRIV_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_PRIV_KEY) --broadcast


deploy:
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop $(NETWORK_ARGS)

clean :; forge clean
	