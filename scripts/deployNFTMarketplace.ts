import { ethers } from 'hardhat';
import fs from 'fs';

async function main() {
    const NFT = await ethers.getContractFactory('NFT_MARKETPLACE');
    const nft = await NFT.deploy();
    await nft.deployed();

    console.log('NFT Marketplace deployed to:', nft.address);

    let config = `export const marketplaceAddress = "${nft.address}"`;

    let data = JSON.stringify(config);
    fs.writeFileSync('configMarketplace.ts', JSON.parse(data));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
