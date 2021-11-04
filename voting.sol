 // SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

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
    
    WorkflowStatus private workflowStatus;
    Proposal[] private proposals;
    bool private isProposalStarted;
    uint private winningProposalId;
    
    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);
    
    // Constructor
    constructor() {
        isProposalStarted = false;
        workflowStatus = WorkflowStatus.RegisteringVoters;
        proposals.push(Proposal('Blank vote', 0));
    }
    
    // We go to the next workflow
    function nextWorkflow() internal {
        emit WorkflowStatusChange(workflowStatus, WorkflowStatus(uint(workflowStatus) + 1));
    }
    
    // Voters register
    function voterRegistration(address _address) public onlyOwner {
        require(WorkflowStatus.RegisteringVoters == workflowStatus, 'Vote is closed.');
        require (!voters[_address].isRegistered, 'Voter is already registred.');
        voters[_address].isRegistered = true;
        voters[_address].hasvoted = false;
        voters[_address].votedProposalId = 0;
        votersAdresses.push(_address);
        emit VoterRegistered(_address);
    }
    
    // The voting proposal begins
    function startProposal() public onlyOwner {
        require(votersAdresses.length > 0, 'No voters found.');
        require(!isProposalStarted, 'A voting session is already underway.');
        isProposalStarted = true;
        nextWorkflow();
    }
    
    // Registration of proposals
    function newProposal(string memory _description) public onlyOwner {
        require(WorkflowStatus.ProposalsRegistrationStarted == workflowStatus,
         'The administrator has not yet started the proposal registration.');
        proposals.description = _description;
        proposals.voteCount = 0;
        proposals.push();
        emit ProposalRegistered(proposals.length);
    }
    
    // End of voting proposals
    function endProposalsRegistration() public onlyOwner {
        require(WorkflowStatus.ProposalsRegistrationStarted == workflowStatus,
         'The administrator has not yet started the proposal registration.');
        nextWorkflow();
    }
    
    // The vote begins
    function startVote() public onlyOwner {
        require(proposals.length > 0, 'No proposals were made.');
        nextWorkflow();
    }
    
    // Submit a vote (with the proposition chosen)
    function submitVote(uint _proposalId) public {
        require(WorkflowStatus.VotingSessionStarted == workflowStatus, 'Voting has not started.');
        require(voters[msg.sender].isRegistered, 'You must first be registered to vote.');
        require(!voters[msg.sender].hasVoted, 'You can vote only once.');
        voters[msg.sender].votedProposalId = _proposalId;
        voters[msg.sender].hasVoted = true;
        proposals[_votedProposalId].voteCount++;
        emit Voted(msg.sender, _proposalId);
    }
    
    // End the vote
    function endVote() public onlyOwner {
        require(WorkflowStatus.VotingSessionStarted == workflowStatus, 'Voting has not started.');
        nextWorkflow();
    }
    
    // Collects votes
    function countsTheVotes() public onlyOwner {
        uint max = 0; // Record number of votes for a proposal
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > max) {
                max = proposals[i].voteCount;
                winningProposalId = proposals[i]._proposalId;
            }
        }
        nextWorkflow();
    }

    function getVoteFromVoters() public view returns (Voter memory) {
        return voters;
    }

    // Absolutely everyone can see the result of the vote
    function getWinner() public view returns (uint) {
        require(WorkflowStatus.VotesTallied == workflowStatus, 'The votes have not been counted.');
        return winningProposalId;
    }

}
