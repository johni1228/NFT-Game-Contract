// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Pausable.sol";

contract Weapon is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint8;

    Counters.Counter private _tokenIdTracker;

    string public baseTokenURI;

    /**
     * @dev typeIdOf will have 3 values - 1: Shield, 2: Axe, 3: Sword, 4: Helmet, 5: Boots, 6: Chainmail, 7: Knife 
     */   
    mapping (uint256 => uint8) tokenIdOf;  // tokenId : the type of character 

    event CreateWeapon(address indexed minter, uint256 indexed tokenId, uint8 indexed typeOf);

    constructor(string memory baseURI) ERC721("Weapon", "WP") {
        setBaseURI(baseURI);
        pause(true);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI QUERY FOR NONE-EXISTENT TOKEN");

        uint8 tokenType = tokenIdOf[tokenId];

        return string(
            abi.encodePacked(
                baseTokenURI,
                tokenType.toString()
            )
        );

    }

    function _totalSupply() internal view returns (uint) {
        return _tokenIdTracker.current();
    }

    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }

    function mint(address _to, uint8 typeOf) public {
        _mintAnElement(_to, typeOf);
    }

    function _mintAnElement(address _to, uint8 typeOf) private {
        uint256 id = _totalSupply();
        _tokenIdTracker.increment();
        _safeMint(_to, id);
        tokenIdOf[id] = typeOf;
        emit CreateWeapon(_to, id, typeOf);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function pause(bool val) public onlyOwner {
        if (val == true) {
            _pause();
            return;
        }
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
}