import { ethers } from 'hardhat';
import fs from 'fs';

async function main() {
    const NFT = await ethers.getContractFactory('NFT_FACTORY');
    const nft = await NFT.deploy('https://www.example.com/api/token/data/');
    await nft.deployed();

    console.log('NFT Factory deployed to:', nft.address);

    let config = `export const nftFactoryAddress = "${nft.address}"`;

    let data = JSON.stringify(config);
    fs.writeFileSync('configFactory.ts', JSON.parse(data));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
