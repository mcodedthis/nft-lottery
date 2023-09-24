// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMinter is ERC721Enumerable, Ownable, IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address[]) private _participants;
    
    bool public isLotteryStarted = false;
    uint256 public ticketPrice = 0.0001 ether;
    uint256 public currentTokenId;

    event LotteryStarted(uint256 tokenId);
    event LotteryEnded(uint256 tokenId, address winner);
    event Participated(uint256 tokenId, address indexed participant);

    constructor() ERC721("MintedNFT", "MNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_baseURI(), _tokenURIs[tokenId]));
    }

    function mintNFTAndStartLottery(string memory _tokenURI) external onlyOwner {
        _tokenIdCounter.increment();
        currentTokenId = _tokenIdCounter.current();
        _safeMint(address(this), currentTokenId);
        setTokenURI(currentTokenId, _tokenURI);
        startLottery();
    }

    function startLottery() internal {
        require(!isLotteryStarted, "Lottery already started");
        require(_participants[currentTokenId].length == 0, "Participants array not reset");
        
        isLotteryStarted = true;
        emit LotteryStarted(currentTokenId);
    }

    function endLottery() external onlyOwner {
        require(isLotteryStarted, "Lottery not started");
        isLotteryStarted = false;

        if (_participants[currentTokenId].length == 0) {
            emit LotteryEnded(currentTokenId, address(0));
            return;
        }

        uint256 randomIndex = random() % _participants[currentTokenId].length;
        address winner = _participants[currentTokenId][randomIndex];
        _transfer(address(this), winner, currentTokenId);

        delete _participants[currentTokenId];
        emit LotteryEnded(currentTokenId, winner);
    }

    function participate() external payable {
        require(isLotteryStarted, "Lottery not started");
        require(msg.value == ticketPrice, "Incorrect ticket price");

        _participants[currentTokenId].push(msg.sender);
        emit Participated(currentTokenId, msg.sender);
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, _participants[currentTokenId])));
    }

    function setTicketPrice(uint256 _price) external onlyOwner {
        ticketPrice = _price;
    }

   function onERC721Received(
    address /* operator */, 
    address /* from */, 
    uint256 /* tokenId */, 
    bytes calldata /* data */
) external pure override returns (bytes4) {
    return this.onERC721Received.selector;
}

}
