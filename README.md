# Blockchain-Technologies-2-Final
# Voting Platform

## Overview
This project is a decentralized voting platform built using Solidity for the smart contract, Vue.js for the front-end, and Vuex for state management. The platform allows users to connect their wallets, add candidates, vote for candidates, and view voting results.

## Prerequisites
- Node.js
- Vue CLI
- MetaMask (or any other Ethereum wallet)

## Getting Started

### 1. Clone the Repository
```sh
git clone <repository-url>
cd voting-platform
```

2. Install Dependencies
```sh
npm install
```

3. Start the Development Server
```sh
npm run serve
```

4. Compile and Deploy the Smart Contract
Make sure you have Ganache or another Ethereum local blockchain running. Then, compile and deploy the smart contract using Truffle or Hardhat.

5. Configure the Smart Contract Address
Update the CONTRACT_ADDRESS in store/index.js with the deployed contract address.

const CONTRACT_ADDRESS = "your_contract_address_here";

6. Open the Application
Open your browser and navigate to http://localhost:8080.




Project Structure:

src/: Contains the Vue.js front-end code.

src/components/: Contains Vue components.

src/store/: Contains Vuex store configuration.

src/views/: Contains the main views of the application.

src/contracts/: Contains the Solidity smart contract and ABI.





Smart Contract:

The smart contract is written in Solidity and provides the following functions:

addCandidate(string memory _name): Adds a new candidate.

vote(uint _candidateId): Votes for a candidate.

getCandidate(uint _candidateId): Returns candidate details.

hasVoted(address _voter): Checks if the user has voted.

endVoting(): Ends the voting session.

startVoting(uint _startTime, uint _endTime): Starts a new voting session.

getWinner(): Returns the winner of the voting session.

getTime(): Returns the current block timestamp.

getAllCandidates(): Returns a string with all candidates and their vote counts.

resetVoting(): Resets the voting state for a new session.
