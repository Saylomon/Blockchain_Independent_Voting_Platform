// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IndependentVotingPlatform {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Vote {
        bool voted;
        uint candidateId;
    }

    mapping(address => Vote) public votes;
    mapping(uint => Candidate) public candidates;

    uint public candidatesCount;
    bool public votingEnded;
    bool public votingStartedFlag;
    uint public votingStartTime;
    uint public votingEndTime;
    address public owner;
    address[] private votersList;

    struct WinnerData {
        uint id;
        string name;
        uint voteCount;
    }

    WinnerData public winnerData;

    event CandidateAdded(uint candidateId, string name);
    event Voted(address indexed voter, uint candidateId);
    event VotingStarted(uint startTime, uint endTime);
    event VotingEnded();
    event WinnerDeclared(uint candidateId, string name, uint voteCount);
    event OwnerTransferred(address indexed previousOwner, address indexed newOwner);

    error NotOwner();
    error VotingNotStarted();
    error VotingAlreadyEnded();
    error VotingNotInProgress();
    error AlreadyVoted();
    error InvalidCandidate();
    error InvalidVotingTime();
    error NoCandidates();
    error NoWinner();
    error VotingStillInProgress();
    error VotingNeverStarted();
    error CannotAddCandidateDuringVoting();
    error CannotEndVotingEarly();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier votingHasStarted() {
        if (!votingStartedFlag) revert VotingNeverStarted();
        _;
    }

    modifier votingNotEnded() {
        if (votingEnded) revert VotingAlreadyEnded();
        _;
    }

    modifier votingInProgress() {
        if (block.timestamp < votingStartTime || block.timestamp > votingEndTime) revert VotingNotInProgress();
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnerTransferred(address(0), owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnerTransferred(owner, newOwner);
        owner = newOwner;
    }

    function addCandidate(string memory _name) public onlyOwner{
        if (block.timestamp >= votingStartTime && block.timestamp <= votingEndTime) {
            revert CannotAddCandidateDuringVoting();
        }
        if (bytes(_name).length == 0) revert NoCandidates();

        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function vote(uint _candidateId) public votingInProgress {
        if (votes[msg.sender].voted) revert AlreadyVoted();
        if (_candidateId == 0 || _candidateId > candidatesCount) revert InvalidCandidate();

        votes[msg.sender] = Vote(true, _candidateId);
        candidates[_candidateId].voteCount++;

        // Добавляем пользователя в список голосовавших (если он еще не в списке)
        votersList.push(msg.sender);

        emit Voted(msg.sender, _candidateId);
    }

    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        if (_candidateId == 0 || _candidateId > candidatesCount) revert InvalidCandidate();
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    function hasVoted(address _voter) public view returns (bool) {
        return votes[_voter].voted;
    }

    function endVoting() public onlyOwner votingHasStarted votingNotEnded {
        if (block.timestamp < votingEndTime) revert CannotEndVotingEarly();

        votingEnded = true;
        emit VotingEnded();
    }

    function startVoting(uint _startTime, uint _endTime) public onlyOwner {
    if (_startTime < block.timestamp) revert InvalidVotingTime();
    if (_startTime >= _endTime) revert InvalidVotingTime();
    if (block.timestamp < votingEndTime && votingStartedFlag) revert VotingStillInProgress();

    // Очистка победителя
    delete winnerData;

    // 🛑 Если голосование уже проводилось, очищаем старые данные
    if (votingStartedFlag) {
        

        // 🔥 Очистка голосов пользователей 🔥
        for (uint i = 0; i < votersList.length; i++) {
            delete votes[votersList[i]];
        }

        // Очистка списка голосовавших
        delete votersList;
    }

    votingStartTime = _startTime;
    votingEndTime = _endTime;
    votingEnded = false;
    votingStartedFlag = true;

    emit VotingStarted(_startTime, _endTime);
}


    function getTime() public view returns (uint) {
        return block.timestamp;
    }

    function getWinner() public onlyOwner votingHasStarted returns (uint, string memory, uint) {
        if (!votingEnded) revert VotingNotStarted();
        if (candidatesCount == 0) revert NoCandidates();

        uint winningCandidateId;
        uint maxVotes = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        if (maxVotes == 0) {
            winnerData = WinnerData(0, "No winner", 0);
            return (0, "No winner", 0);
        }

        Candidate memory winner = candidates[winningCandidateId];
        winnerData = WinnerData(winner.id, winner.name, winner.voteCount);

        for (uint i = 1; i <= candidatesCount; i++) {
            delete candidates[i];
        }
        candidatesCount = 0;

        emit WinnerDeclared(winner.id, winner.name, winner.voteCount);
        return (winner.id, winner.name, winner.voteCount);
    }

    function fetchWinner() public view returns (uint, string memory, uint) {
        return (winnerData.id, winnerData.name, winnerData.voteCount);
    }
}
