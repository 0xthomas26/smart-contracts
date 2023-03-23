# Smart Contracts

# Compile smart contracts

npx hardhat compile

# Deploy locally

npx hardhat node

npx hardhat run --network localhost scripts/deployNFTFactory.ts

npx hardhat run --network localhost scripts/deployNFTMarketplace.ts

# Run tests

npx hardhat test test/NFT_tools.ts
