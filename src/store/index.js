import { createStore } from 'vuex';
const ethers = require('ethers');

const Provider = new ethers.providers.JsonRpcProvider(process.env.VUE_APP_GOERLI_RPC_URL);
const CONTRACT_ADDRESS = "0xb6f8a477D1572faB0632E5aFB787e974d2595f42";
import { ABI } from '@/contracts/IVP.abi.js';

export default createStore({
  state: {
    provider: Provider,
    signer: null,
    contract: null,
    wallet: {
      address: null,
      chain: null,
      chainId: null,
    },
    candidates: [],
    votingStatus: {
      started: false,
      ended: false,
    },
    currentTime: null,
    winner: null,
    results: [],
    electionResult: null, // Добавлено состояние electionResult
    votingEnded: null,
    owner: null,  // 🔥 Новый state для хранения владельца
  },
  getters: {
    getCandidateById: (state) => (id) => {
      return state.candidates.find(candidate => candidate.id === id);
    }
  },
  mutations: {
    setOwner(state, owner) {  // 🔥 Добавляем мутацию для сохранения владельца
      state.owner = owner;
    },
    setCurrentTime(state, time) {
      state.currentTime = time;
    },
    setSigner(state, signer) {
      state.signer = signer;
    },
    setContract(state, contract) {
      state.contract = contract;
    },
    setWalletAddress(state, address) {
      state.wallet.address = address;
    },
    setChain(state, chain) {
      state.wallet.chain = chain;
    },
    setChainId(state, chainId) {
      state.wallet.chainId = chainId;
    },
    setCandidates(state, candidates) {
      state.candidates = candidates;
    },
    setVotingStatus(state, status) {
      state.votingStatus = status;
    },
    setWinner(state, winner) {
      state.winner = winner;
    },
    setResults(state, results) {
      state.results = results;
    },
    setElectionResult(state, result) { // Добавлено изменение electionResult
      state.electionResult = result;
    },
    setVotingEnded(state, votingEnd) {
      state.votingEnded = votingEnd
    }
  },
  actions: {
    async connectWallet({ commit, state }) {
      try {
        if (typeof window.ethereum !== 'undefined') {
          console.log("Ethereum client installed!");
          if (ethereum.isMetaMask === true) {
            console.log("Metamask installed!");
            if (!ethereum.isConnected()) {
              console.log("Metamask is not connected!");
              await ethereum.enable();
            }
            console.log("Metamask connected!");
          } else {
            alert("Metamask is not installed!");
            return;
          }
        } else {
          alert("Ethereum client is not installed!");
          return;
        }

        const accounts = await ethereum.request({ method: "eth_requestAccounts" });
        commit('setWalletAddress', accounts[0]);
        console.log(`Account ${accounts[0]} connected`);

        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const network = await provider.getNetwork();
        commit('setChain', network.name);
        commit('setChainId', network.chainId);

        const signer = provider.getSigner();
        commit('setSigner', signer);

        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
        commit('setContract', contract);

        ethereum.on('accountsChanged', async (accounts) => {
          commit('setWalletAddress', accounts[0]);
          console.log(`Account ${accounts[0]} connected`);
        });

        ethereum.on('chainChanged', async () => {
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          const network = await provider.getNetwork();
          commit('setChain', network.name);
          commit('setChainId', network.chainId);

          const signer = provider.getSigner();
          commit('setSigner', signer);

          const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
          commit('setContract', contract);
        });
      } catch (error) {
        console.error("Error connecting wallet:", error);
        throw error;
      }
    },
    async getOwner({ commit, state }) {
      try {
        const owner = await state.contract.owner();  // Вызов метода getOwner()
        console.log("Contract owner:", owner);
        commit('setOwner', owner);
      } catch (error) {
        console.error("Error getting contract owner:", error);
      }
    },
    async getCandidates({ commit, state }) {
      try {
        const candidates = await state.contract.getCandidates();
        commit('setCandidates', candidates);
      } catch (error) {
        console.error("Error getting candidates:", error);
      }
    },
    async vote({ state, dispatch }, candidateId) {
      try {
        await state.contract.vote(candidateId);
        await dispatch('fetchCandidates');
      } catch (error) {
        console.error("Error voting:", error);
        throw error;
      }
    },
    async getVoteStatus({ commit, state }) {
      try {
        const votingEnd = await state.contract.votingEnded()
        console.log("🔥 Voting Ended Status from contract:", votingEnd);
        commit('setVotingEnded', votingEnd)
      } catch (error) {
        console.error("Error getting candidates:", error);
      }
    },
    async startVoting({ commit, state }, { startTime, endTime }) {
      try {
        console.log("Starting Voting with times:", startTime, endTime);
        const tx = await state.contract.startVoting(startTime, endTime);
        await tx.wait();
        commit('setVotingStatus', { started: true, ended: false });
      } catch (error) {
        console.error("Error starting voting:", error);
        throw error;
      }
    },
    async checkIfVoted({ state }, voterAddress) {
      try {
        if (!state.contract) {
          console.error("Contract is not initialized.");
          return false;
        }
        
        const hasVoted = await state.contract.hasVoted(voterAddress);
        console.log(`User ${voterAddress} has voted: ${hasVoted}`);
        return hasVoted;
      } catch (error) {
        console.error("Error checking voting status:", error);
        return false;
      }
    },    
    async endVoting({ commit, state }) {
      try {
        const tx = await state.contract.endVoting();
        await tx.wait();
        commit('setVotingStatus', { started: false, ended: true });
      } catch (error) {
        console.error("Error ending voting:", error);
      }
    },
    async addCandidate({ commit, state }, candidateName) {
      console.log('Candidate Name: ', candidateName)
      try {
        const tx = await state.contract.addCandidate(candidateName);
        await tx.wait();
      } catch (error) {
        console.error("Error adding candidate:", error);
      }
    },
    async getWinner({ state, commit }) {
      try {
        const result = await state.contract.fetchWinner(); // Вызов функции getWinner контракта
    
        commit('setElectionResult', {
          candidateId: result[0].toNumber(),
          candidateName: result[1],
          voteCount: result[2].toNumber()
        });
    
      } catch (error) {
        console.error("Error getting winner:", error);
        throw error;
      }
    },
    async getTime({ commit, state }) {
      try {
        const currentTime = await state.contract.getTime();
        commit('setCurrentTime', currentTime.toNumber());
      } catch (error) {
        console.error("Error getting current time:", error);
      }
    },
    async fetchElectionResult({ state, commit }) {
      try {
        console.log("🔹 Fetching election result...");
    
        // 🔍 Проверяем, завершено ли голосование
        const votingEnded = await state.contract.votingEnded();
        if (!votingEnded) {
          console.warn("⚠️ Voting is not ended yet.");
          commit("setElectionResult", null);
          return;
        }
    
        // 🔍 Проверяем, есть ли кандидаты
        const candidatesCount = await state.contract.candidatesCount();
        if (candidatesCount.toNumber() === 0) {
          console.warn("⚠️ No candidates available.");
          commit("setElectionResult", null);
          return;
        }
    
        // 🔍 Проверяем, есть ли голоса
        let totalVotes = 0;
        for (let i = 1; i <= candidatesCount.toNumber(); i++) {
          const candidate = await state.contract.candidates(i);
          totalVotes += candidate.voteCount.toNumber();
        }
    
        if (totalVotes === 0) {
          console.warn("⚠️ No votes were cast. No winner.");
          commit("setElectionResult", null);
          return;
        }
    
        // 🏆 Запрашиваем победителя
        const result = await state.contract.getWinner();
    
        console.log("🏆 Winner received:", result);
    
        // 📝 Обновляем state (getWinner() возвращает массив, не объект)
        commit("setElectionResult", {
          candidateId: result[0].toNumber(),
          candidateName: result[1],
          voteCount: result[2].toNumber(),
        });
    
      } catch (error) {
        console.error("❌ Error fetching election result:", error);
    
        if (
          error.message.includes("NoWinner") ||
          error.message.includes("No candidates") ||
          error.message.includes("Voting has not ended")
        ) {
          console.warn("⚠️ No valid results found.");
          commit("setElectionResult", null);
        } else {
          alert(`⚠️ Unexpected error: ${error.message}`);
        }
      }
    },    
    async fetchCandidates({ state, commit }) {
      try {
        const candidates = [];
        const count = await state.contract.candidatesCount();
        for (let i = 1; i <= count; i++) {
          const candidate = await state.contract.candidates(i);
          candidates.push({ id: candidate.id, name: candidate.name, voteCount: candidate.voteCount });
        }
        commit('setCandidates', candidates);
      } catch (error) {
        console.error("Error fetching candidates:", error);
        throw error;
      }
    },
  },
  modules: {}
});
