// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTMintRaffle is ERC721Enumerable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _entryCounter;

    mapping(uint256 => address) public raffleEntries;
    mapping(address => uint256) public escrow;
    mapping(uint256 => string) public tokenURIs; // Mapping to store token URIs

    bool public raffleOpen = false;
    uint256 public ticketPrice = 0.0001 ether;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() ERC721("NFTMintRaffle", "NMR") {
        owner = msg.sender;
    }

    function mintNFTWithImage(string memory tokenURI, string memory imageURI) external onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _mint(msg.sender, tokenId);

        // Set the token URI in the mapping
        tokenURIs[tokenId] = tokenURI;

        // Emit an event with the image URI for reference
        emit ImageURISet(tokenId, imageURI);
    }

    function enterRaffle() external payable {
        require(raffleOpen, "Raffle is not open");
        require(msg.value == ticketPrice, "Invalid ticket price");

        escrow[msg.sender] = escrow[msg.sender].add(msg.value);

        _entryCounter.increment();
        raffleEntries[_entryCounter.current()] = msg.sender;
    }

    function startRaffle() external onlyOwner {
        raffleOpen = true;
    }

    function endRaffleAndDistribute() external onlyOwner {
        require(raffleOpen, "Raffle should be open to end");
        raffleOpen = false;

        uint256 totalEntries = _entryCounter.current();
        uint256 totalNFTs = _tokenIdCounter.current();

        uint256 winnersCount = (totalNFTs % 2 == 0) ? totalNFTs / 2 : (totalNFTs + 1) / 2;

        require(totalEntries >= winnersCount, "Not enough participants");

        for (uint256 i = 0; i < winnersCount; i++) {
            uint256 randomEntry = randomMod(totalEntries) + 1;

            _safeTransfer(address(this), raffleEntries[randomEntry], i + 1, "");

            // Refund funds to non-winners
            if (i != randomEntry) {
                payable(raffleEntries[i]).transfer(ticketPrice);
                escrow[raffleEntries[i]] = escrow[raffleEntries[i]].sub(ticketPrice);
            }

            raffleEntries[randomEntry] = raffleEntries[totalEntries];
            totalEntries--;
        }

        _entryCounter.reset();
    }

    function randomMod(uint256 _modulus) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % _modulus;
    }

    // Event to log the image URI associated with a token
    event ImageURISet(uint256 indexed tokenId, string imageURI);
}
