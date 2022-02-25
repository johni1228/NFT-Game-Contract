pragma solidity ^0.6.0;

import "./General.sol";

Contract Battle {

    mapping (address => uint256) maticBalanceOf;

    event Withdraw(bool indexed success, bytes indexed data);
    event Deposit(address indexed sender, uint256 indexed amount);

    function feedBattle(uint _generalId, uint _targetId) external ownerOf(_generalId) {
        General storage myGeneral = generals[_generalId];
        General storage enemyGeneral = generals[_targetId];
        uint rand = randMod(100);
        if (rand <= attackVictoryProbability) {
        myGeneral.winCount++;
        myGneral.level++;
        enemyGeneral.lossCount++;
        feedAndMultiply(_generalId, enemyGeneral.weapon, enemyGeneral.life);
    }

    function deposit() external payable {
        require(msg.value > 0);
        address sender = msg.sender;
        uint256 deposited = msg.value;
        address receiver = address(this);
        maticBalanceOf[sender] = deposited;
        receiver.transfer(deposited);
        emit Deposit(sender, deposited);
    }

    function widthdraw() external payable {
        uint256 balance = maticBalanceOf(msg.sender);
        require(balance > 0);

        (bool success, bytes memory data) = address(msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
        emit Withdraw(success, data);
    }
}