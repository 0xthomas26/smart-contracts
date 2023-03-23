import chai from 'chai';
import { ethers } from 'hardhat';
import { solidity } from 'ethereum-waffle';
import type { NFT_MARKETPLACE, NFT_FACTORY } from '../typechain-types';

chai.use(solidity);
const { expect } = chai;

describe('NFT_FACTORY Contract', () => {
    let nftFactory: NFT_FACTORY;

    before(async () => {
        const NFTFactory = await ethers.getContractFactory('NFT_FACTORY');

        nftFactory = await NFTFactory.deploy('https://www.example.com/api/token/data/');
    });

    it('Should deploy NFT_FACTORY contract', async () => {
        expect(nftFactory.address).to.not.be.null;
    });

    it('Should mint 2 new NFTs', async () => {
        await nftFactory.mintFactory(2);

        const nbNFTs = await nftFactory.totalSupply();
        expect(nbNFTs).to.equal(2);

        const tokenURI = await nftFactory.tokenURI(1);
        expect(tokenURI).to.equal('https://www.example.com/api/token/data/1');

        const tokenURI2 = await nftFactory.tokenURI(2);
        expect(tokenURI2).to.equal('https://www.example.com/api/token/data/2');
    });
});

describe('NFT_MARKETPLACE Contract', () => {
    let nftMarketplace: NFT_MARKETPLACE;
    let nftFactory: NFT_FACTORY;
    let owner: any;
    let seller1: any;
    let buyer1: any;

    before(async () => {
        const NFTMarketplace = await ethers.getContractFactory('NFT_MARKETPLACE');
        const NFTFactory = await ethers.getContractFactory('NFT_FACTORY');

        [owner, buyer1] = await ethers.getSigners();

        nftFactory = await NFTFactory.deploy('https://www.example.com/api/token/data/');
        await nftFactory.mintFactory(1);

        nftMarketplace = await NFTMarketplace.deploy();
    });

    it('Should deploy NFT_MARKETPLACE contract', async () => {
        expect(nftMarketplace.address).to.not.be.null;
    });

    it('should list an NFT on the marketplace', async () => {
        const tokenId = 1;
        const price = ethers.utils.parseEther('1');
        const listingFee = await nftMarketplace.LISTING_FEE();

        await nftFactory.connect(owner).setApprovalForAll(nftMarketplace.address, true);

        await nftMarketplace.connect(owner).listNft(nftFactory.address, tokenId, price, {
            value: listingFee,
        });

        const nft = await nftMarketplace.getNft(tokenId);
        expect(nft.nftContract).to.equal(nftFactory.address);
        expect(nft.tokenId).to.equal(tokenId);
        expect(nft.seller).to.equal(owner.address);
        expect(nft.owner).to.equal(nftMarketplace.address);
        expect(nft.price).to.equal(price);
        expect(nft.listed).to.be.true;
    });

    it('Should buy NFT from marketplace', async () => {
        await nftMarketplace
            .connect(buyer1)
            .buyNft(nftFactory.address, 1, { value: ethers.utils.parseEther('1') });

        const ownerAddress = await nftFactory.ownerOf(1);
        expect(ownerAddress).to.equal(buyer1.address);
    });
});
