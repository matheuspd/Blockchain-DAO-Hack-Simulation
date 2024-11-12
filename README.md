# Blockchain-DAO-Hack-Simulation

Simple simulation of the DAO Hack vulnerability using smart contracts on Remix IDE for the Crypto and Blockchain discipline.

The attack consists in deploying the Vulnerable_DAO contract and one of the 2 Hack contracts using the DAO address.
Then you can make a separated deposit in the DAO and run the attack function in the hacker contract using at least 1 Ether.
This function will drain all the Ether that the DAO owns through a reentrancy attack.
