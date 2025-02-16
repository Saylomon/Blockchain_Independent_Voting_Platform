// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract IndependentVotingPlatform is Ownable {
    // Структура для хранения информации о кандидате
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // Структура для хранения информации о голосах
    struct Vote {
        bool voted;
        uint candidateId;
    }

    // Маппинг для хранения информации о голосах
    mapping(address => Vote) public votes;

    // Маппинг для хранения информации о кандидатах
    mapping(uint => Candidate) public candidates;

    // Счетчик кандидатов
    uint public candidatesCount;

    // Флаг для проверки завершения голосования
    bool public votingEnded;

    // Время начала и окончания голосования
    uint public votingStartTime;
    uint public votingEndTime;

    // События
    event CandidateAdded(uint candidateId, string name);
    event Voted(address voter, uint candidateId);
    event VotingEnded();
    event VotingStarted(uint startTime, uint endTime);

    // Модификатор для проверки, что голосование еще не завершено
    modifier votingNotEnded() {
        require(!votingEnded, "Voting has already ended");
        _;
    }

    // Модификатор для проверки, что голосование началось
    modifier votingStarted() {
        require(block.timestamp >= votingStartTime, "Voting has not started yet");
        _;
    }

    // Модификатор для проверки, что голосование в процессе
    modifier votingInProgress() {
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Voting is not in progress");
        _;
    }

    constructor() Ownable(msg.sender) {
        // The deployer is automatically set as the initial owner by the Ownable constructor
    }

    // Функция добавления нового кандидата
    function addCandidate(string memory _name) public onlyOwner votingNotEnded {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");

        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);

        emit CandidateAdded(candidatesCount, _name);
    }

    // Функция для голосования
    function vote(uint _candidateId) public votingInProgress {
        require(!votes[msg.sender].voted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        votes[msg.sender] = Vote(true, _candidateId);
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    // Функция для получения информации о кандидате
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    // Функция проверки, проголосовал ли пользователь
    function hasVoted(address _voter) public view returns (bool) {
        return votes[_voter].voted;
    }

    // Функция завершения голосования
    function endVoting() public onlyOwner votingNotEnded {
        votingEnded = true;
        emit VotingEnded();
    }

    // Функция начала голосования с указанием времени
    function startVoting(uint _startTime, uint _endTime) public onlyOwner votingNotEnded {
        require(_startTime < _endTime, "Start time must be before end time");
        votingStartTime = _startTime;
        votingEndTime = _endTime;
        emit VotingStarted(_startTime, _endTime);
    }

    // Функция для получения всех кандидатов с их голосами
    function getAllCandidates() public view returns (string memory) {
        require(votingEnded, "Voting has not ended yet");

        string memory result = "";
        for (uint i = 1; i <= candidatesCount; i++) {
            Candidate memory candidate = candidates[i];
            result = string(abi.encodePacked("\n", result, "ID: ", uintToString(candidate.id), ", Name: ", candidate.name, ", Vote Count: ", uintToString(candidate.voteCount), "\n"));
        }
        return result;
    }

    // Функция для получения текущего времени блока
    function getTime() public view returns (uint) {
        return block.timestamp;
    }

    // Вспомогательная функция для преобразования uint в string
    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1];
        }
        string memory str = string(s);
        return str;
    }

    // Функция для получения победителя голосования и удаления всех кандидатов
    function getWinner() public onlyOwner returns (uint, string memory, uint) {
        require(votingEnded, "Voting has not ended yet");

        uint winningCandidateId;
        uint maxVotes = 0;

        // Находим кандидата с максимальным количеством голосов
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        Candidate memory winner = candidates[winningCandidateId];

        // Удаляем всех кандидатов
        for (uint i = 1; i <= candidatesCount; i++) {
            delete candidates[i];
        }
        candidatesCount = 0;

        return (winner.id, winner.name, winner.voteCount);
    }
}
