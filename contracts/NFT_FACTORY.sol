// SPDX-License-Identifier: Unlicense
// Specify the license for your contract

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT_FACTORY is ERC721Enumerable, Ownable {

    using Strings for uint256;
    using Counters for Counters.Counter;

    // Counter to keep track of token IDs
    Counters.Counter private _tokenIds;

    // Base URI for metadata of the NFTs
    string public baseURI;

    // Pause state of the contract
    bool public paused = false;

    // Maximum number of NFTs that can be minted in the launchpad
    uint256 public LAUNCH_MAX_SUPPLY = 20;

    // Current number of NFTs minted in the launchpad
    uint256 public LAUNCH_SUPPLY = 0;

    // Address of the launchpad contract
    address public LAUNCHPAD = address(0);

    // Modifier to restrict certain functions to the launchpad contract
    modifier onlyLaunchpad() {
        require(LAUNCHPAD != address(0), "launchpad address must be set");
        require(msg.sender == LAUNCHPAD, "must be called by launchpad");
        _;
    }

    // Function to set the maximum launch supply, only callable by the contract owner
    function setMaxLaunchpadSupply(uint256 _launch_max_supply) public onlyOwner {
        LAUNCH_MAX_SUPPLY = _launch_max_supply;
    }

    // Function to set the current launch supply, only callable by the contract owner
    function setLaunchpadSupply(uint256 _launch_supply) public onlyOwner {
        LAUNCH_SUPPLY = _launch_supply;
    }

    // Function to set the launchpad contract address, only callable by the contract owner
    function setLaunchpadContract(address _launchpad) public onlyOwner {
        LAUNCHPAD = _launchpad;
    }

    // Function to get the maximum launch supply
    function getMaxLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_MAX_SUPPLY;
    }

    // Function to get the current launch supply
    function getLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_SUPPLY;
    }

    // Constructor to set the base URI for metadata of the NFTs
    constructor(
        string memory _initBaseURI
    ) ERC721("NFT Factory", "NFTF") {
        setBaseURI(_initBaseURI);
    }

    // Function to set the base URI for metadata of the NFTs, only callable by the contract owner
    function setBaseURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    // Function to return the base URI for metadata of the NFTs
    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }

    // Function to set the pause state of the contract, only callable by the contract owner
    function setPause(bool _state) public onlyOwner {
        paused = _state;
    }

    // Function to mint by the contract owner
    function mintFactory(uint256 _mintAmount) public onlyOwner {
        // Require that the contract is not paused and the mint amount is greater than 0
        require(!paused, "the contract is paused");
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        
        uint256 _newItemId;
        // Mint the specified amount of NFTs
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _tokenIds.increment();
            _newItemId = _tokenIds.current();
            _safeMint(msg.sender, _newItemId);
        }
    }

    // Function to mint via the launchpad
    function mintTo(address to, uint size) external onlyLaunchpad {
        // Require that the recipient address is not empty, size is greater than 0, and the max supply has not been reached
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must greater than zero");
        require(LAUNCH_SUPPLY + size <= LAUNCH_MAX_SUPPLY, "max supply reached");

        uint256 _newItemId;
        // Mint the specified amount of NFTs to the recipient address
        for (uint256 i=1; i <= size; i++) {
            _tokenIds.increment();
            _newItemId = _tokenIds.current();
            _mint(msg.sender, _newItemId);
            LAUNCH_SUPPLY++;
        }
    }

    // Function to withdraw from contract
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
}