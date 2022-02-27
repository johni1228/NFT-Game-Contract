// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Character.sol";

contract BattleManager is Ownable {

    using SafeMath for uint256;

    bool private _isUpgradableLife;
    bool private _isUpgradableDefence;
    bool private _isUpgradableAttack;

    bool public isEndBattle;
    address private winner;

    mapping (address => uint256) public maticBalanceOf;

    event Withdraw(bool indexed success, bytes indexed data);
    event Deposit(address indexed sender, uint256 indexed amount);

    struct BattleMember {
        address member;
        uint256 characterId;
    }
    
    uint memberSize = 2;
    BattleMember[] battleMemebers = new BattleMember[](memberSize);

    modifier onlyEndBattle {
        require(isEndBattle, "Battle start or processing");
        _;
    }

    modifier onlyWinner(address caller) {
        require(caller != address(0), "Don't be zero address");
        require(caller == winner, "only winner");
        _;
    }

    function startBattle(address firstAddress, uint256 firstCharacterId, address secondAddress, uint256 secondCharacterId) external {
        BattleMember memory firstMember = BattleMember(firstAddress, firstCharacterId);
        BattleMember memory secondMember = BattleMember(secondAddress, secondCharacterId);
        battleMemebers.push(firstMember);
        battleMemebers.push(secondMember);
    }

    function _initUpgradable() private {
        _isUpgradableAttack = false;
        _isUpgradableDefence = false;
        _isUpgradableLife = false;
    }

    function setWinner(address _address) external {
        winner = _address;
    }

    function endBattle() external onlyOwner {
        isEndBattle = true;        
        _initUpgradable();
    }

    function deposit() external payable {
        require(msg.value > 0);
        address sender = msg.sender;
        uint256 deposited = msg.value;
        address receiver = address(this);
        maticBalanceOf[sender] = maticBalanceOf[sender].add(deposited);
        receiver.transfer(deposited);
        emit Deposit(sender, deposited);
    }

    function widthdraw() external payable onlyEndBattle {
        uint256 balance = maticBalanceOf(msg.sender);
        require(balance > 0);
        (bool success, bytes memory data) = address(msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
        emit Withdraw(success, data);
    }

    function upgradeLife() external onlyWinner(msg.sender) onlyEndBattle {
        require(!_isUpgradableLife, "Upgrade life");
        if(battleMemebers[0].member == msg.sender)
            _upgradeLife(battleMemebers[0].characterId);
        else _upgradeLife(battleMemebers[1].characterId);
        _isUpgradableLife = true;
    }

    function upgradeDefence() external onlyWinner(msg.sender) onlyEndBattle {
        require(!_isUpgradableDefence, "Upgrade life");
        if(battleMemebers[0].member == msg.sender)
            _upgradeDefence(battleMemebers[0].characterId);
        else _upgradeDefence(battleMemebers[1].characterId);
        _isUpgradableDefence = true;
    }

    function upgradeAttack() external onlyWinner(msg.sender) onlyEndBattle {
        require(!_isUpgradableAttack, "Upgrade life");
        if(battleMemebers[0].member == msg.sender)
            _upgradeAttack(battleMemebers[0].characterId);
        else _upgradeAttack(battleMemebers[1].characterId);
        _isUpgradableAttack = true;
    }
}