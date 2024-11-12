// SPDX-License-Identifier: UNIDENTIFIED
pragma solidity ^0.8.10;

contract Simple_Fixed_DAO {
    struct Proposal {
        address proposal_addr;
        uint256 cost;
        uint256 votes;
        bool approved;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposal_count;

    mapping(address => uint256) public shares;
    uint256 public total_shares;
    uint256 public total_funds;

    
    /*
    Allows users to deposit Ether into the DAO 
    and receive "shares" in return
    */
    function deposit() public payable {
        require(msg.value > 0, "Ether required");
        // User receive the same amount of Ether as "shares"
        shares[msg.sender] += msg.value;
        // Update total shares and funds from the DAO
        total_shares += msg.value;
        total_funds += msg.value;
    }

    /*
    Create a new investment proposal
    */
    function create_proposal(address proposal_addr, uint256 cost) public {
        require(cost <= total_funds, "Proposal cost exceeds DAO balance");
        // Storage the proposal with its initial values
        // and adds the proposal count variable
        Proposal storage proposal = proposals[proposal_count];
        proposal.proposal_addr = proposal_addr;
        proposal.cost = cost;
        proposal.votes = 0;
        proposal.approved = false;
        proposal_count++;
    }

    /*
    Allows shareholders to vote on a proposal
    */
    function vote(uint256 proposal_id) public {
        Proposal storage proposal = proposals[proposal_id];
        require(shares[msg.sender] > 0, "Must be a DAO member");
        require(!proposal.voted[msg.sender], "Already voted");

        proposal.votes += shares[msg.sender];
        proposal.voted[msg.sender] = true;
    }

    /*
    Execute the proposal if the majority of shareholders agree
    */ 
    function execute_proposal(uint256 proposal_id) public {
        Proposal storage proposal = proposals[proposal_id];
        require(proposal.votes > total_shares / 2, "Not enough votes");
        require(!proposal.approved, "Proposal already approved");
        require(proposal.cost <= total_funds, "Proposal cost exceeds DAO balance");

        // Send Ether to execute the proposal
        (bool sent, ) = proposal.proposal_addr.call{value: proposal.cost}("");
        require(sent, "Failed to send Ether");

        proposal.approved = true;
        total_funds -= proposal.cost;
    }

    /*
    Allows shareholders to withdraw their funds.
    ***** Fixed for reentrancy attacks *****
    */
    function withdraw() public {
        uint256 balance = shares[msg.sender];
        require(balance > 0, "No balance to withdraw");

        // Updates user balance before sending Ether
        shares[msg.sender] = 0;
        total_shares -= balance;
        total_funds -= balance;

        // Send Ether to user after updating balance
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Withdrawal failed");        
    }
}
