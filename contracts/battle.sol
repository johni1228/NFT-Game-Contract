pragma solidity ^0.6.0;

import "./General.sol";

Contract Battle {
    function attack(uint _generalId, uint _targetId) external ownerOf(_generalId) {
        General storage myGeneral = generals[_generalId];
        General storage enemyGeneral = generals[_targetId];
        uint rand = randMod(100);
        if (rand <= attackVictoryProbability) {
        myGeneral.winCount++;
        myGneral.level++;
        enemyGeneral.lossCount++;
        feedAndMultiply(_generalId, enemyGeneral.weapon, enemyGeneral.life);
    }
}