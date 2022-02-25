// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Pausable.sol";
import "./charactor.sol";
import "./weapon.sol";

contract Generol is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    address public constant creatorAddress = 0x4B3aacFd767D7F030984E4cD4261927De5c0bcF6; // TODO: update
    address public constant devAddress = 0x4B3aacFd767D7F030984E4cD4261927De5c0bcF6; // TODO: update
    string public baseTokenURI;

    event CreateGeneral(uint256 indexed id, Character indexed character, Weapon indexed weapon);
    constructor(string memory baseURI) ERC721("Generol", "GNE") {
        setBaseURI(baseURI);
        pause(true);
    }

    function _totalSupply() internal view returns (uint) {
        return _tokenIdTracker.current();
    }

    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }
    function mint(address _to) public {
        uint256 _characterId = characterOf[_to];
        uint256 _weaponId = weaponOf[_to];
        Character character = characters[_characterId];
        Weapon weapon = weapons[_weaponId];
        _mintAnElement(_to);
    }
    function _mintAnElement(address _to, Character _character, Weapon _weapon) private {
        uint id = _totalSupply();
        _tokenIdTracker.increment();
        _safeMint(_to, id);
        emit CreateGeneral(id, _character, _weapon);
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

    function upgardCharacter(address _to, Character _character) external {
        uint256 id = balanceOf(_to);
        _burn(id);
        Weapon weapon = weapons[id];
        _mintAnElement(_to, _character, weapon);
    }

    function upgardWeapon(address _to, Weapon _weapon) external {
        uint256 id = balanceOf(_to);
        _burn(id);
        Character character = characters[id];
        _mintAnElement(_to, _weapon, character);
    }
    
}