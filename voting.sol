 // SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    
    struct Proposal {
        string description;
        uint voteCount;
    }
    
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }
    
    mapping(address => Voter) private voters;
    
    uint private winningProposalId;
    WorkflowStatus private workflowStatus;
    bool private isProposalStarted;
    Proposal[] private proposals;
    uint private maxCount = 0;
    uint private winningProposalId;
    
    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);
    
    // Constructor
    constructor() {
        workflowStatus = WorkflowStatus.RegisteringVoters;
    }
    
    // We go to the next workflow
    function nextWorkflow() internal {
        emit WorkflowStatusChange(workflowStatus, WorkflowStatus(uint(oldStatus) + 1));
    }
    
    // Voters register
    function voterRegistration(address _address) public onlyOwner {
        require(WorkflowStatus.RegisteringVoters == workflowStatus, 'Vote is closed.');
        require (!voters[_address].isRegistered, 'Voter is already registred.');
        voters[_address] = Voter ({
            isRegistered: true,
            hasVoted: false,
            votedProposalId: 0
        });
        emit VoterRegistered(_address);
    }
    
    // The voting proposal begins
    function startProposal() public onlyOwner {
        require(!isProposalStarted, 'A voting session is already underway.');
        isProposalStarted = true;
        nextWorkflow();
    }
    
    // Registration of proposals
    function whichProposal(string memory _description) public onlyOwner {
        require(WorkflowStatus.ProposalsRegistrationStarted == workflowStatus, 'The administrator has not yet validated the voter registration.');
        proposals.push(Proposal({
            description: _description,
            voteCount: 0
        }));
        emit ProposalRegistered(proposals.length);
    }
    
    // End of voting proposals
    function endProposal() public onlyOwner {
        emit ProposalRegistered(proposals.length);
    }
    
    // The vote begins
    function startVote() public onlyOwner {
        require(proposals.length > 0, 'No proposals were made.');
        nextWorkflow();
    }
    
    // Submit a vote
    function submitVote(uint _proposalId) public {
        require(WorkflowStatus.VotingSessionStarted == workflowStatus, 'Voting has not started.');
        require(voters[msg.sender].isRegistered, 'You must first be registered to vote.');
        voters.push(Voter ({
            isRegistered: false,
            hasVoted: true,
            votedProposalId: _proposalId
        }));
        emit Voted(_address, _proposalId);
    }
    
    // End the vote
    function endVote() public onlyOwner {
        require(WorkflowStatus.VotingSessionStarted == workflowStatus, 'Voting has not started.');
        nextWorkflow();
    }
    
    // Collects votes
    function getVotes() public onlyOwner {
        return voters;
    }
    
    // Winning proposal
    function getWinningProposal() public view returns (uint winningProposalId) {
        require(WorkflowStatus.VotesTallied == workflowStatus, 'Voting is not over.')
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxCount) {
                 maxCount = proposals[i].voteCount;
                 winningProposalId = proposals[i].index;
            }
        }
        return winningProposalId;
    }
    
}