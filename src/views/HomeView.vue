<template>
  <div class="home">
    <!-- 🟣 Блок информации о кошельке -->
    <div class="card wallet-info">
      <h1>Voting Platform</h1>
      <button @click="connectWalletHandler">Connect Wallet</button>

      <div v-if="wallet.address">
        <p><strong>Wallet Address:</strong> {{ wallet.address }}</p>
        <p><strong>Chain:</strong> {{ wallet.chain }}</p>
        <p><strong>Chain ID:</strong> {{ wallet.chainId }}</p>
      </div>
    </div>

    <!-- 🔵 Блок голосования -->
    <div class="card vote-section">
      <h1>Vote for Candidate</h1>
      <div class="input-group">
        <input v-model="candidateId" placeholder="Candidate ID" />
        <button @click="voteHandler">Vote</button>
      </div>
    </div>

    <!-- ⚪ Блок списка кандидатов -->
    <div class="card candidates-list">
      <h1>Candidates List</h1>
      <ul v-if="candidates.length > 0">
        <li v-for="candidate in candidates" :key="candidate.id">
          <p><strong>ID:</strong> {{ candidate.id }}</p>
          <p><strong>Name:</strong> {{ candidate.name }}</p>
          <p><strong>Votes:</strong> {{ candidate.voteCount }}</p>
        </li>
      </ul>
      <div v-else>
        <p>No candidates available.</p>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState, mapActions } from 'vuex';

export default {
  data() {
    return {
      candidateId: null
    };
  },
  computed: {
    ...mapState(['wallet', 'candidates', 'votingEnded'])
  },
  methods: {
    ...mapActions(['connectWallet', 'vote', 'fetchCandidates', 'getVoteStatus', 'checkIfVoted']),

    async connectWalletHandler() {
      try {
        await this.connectWallet();
        await this.fetchCandidates();
        await this.getVoteStatus();
      } catch (error) {
        console.error("Error connecting wallet:", error);
        alert(`Error connecting wallet: ${error.message}`);
      }
    },
    async voteHandler() {
      try {
        await this.getVoteStatus();

        if (this.votingEnded) {
          alert("⚠️ Voting has already ended.");
          return;
        }

        if (!this.wallet.address) {
          alert("⚠️ Wallet not connected.");
          return;
        }

        const hasVoted = await this.checkIfVoted(this.wallet.address);
        if (hasVoted) {
          alert("⚠️ You have already voted. You cannot vote again.");
          return;
        }

        await this.vote(Number(this.candidateId));
        this.candidateId = null;
      } catch (error) {
        console.error("Error voting:", error);
        alert(`Error voting: ${error.message}`);
      }
    },
  },
  async mounted() {
    if (this.wallet.address) {
      await this.fetchCandidates();
      await this.getVoteStatus();
    }
  }
};
</script>



<style scoped>
/* 🌟 Глобальные стили */
.home {
  padding: 140px 20px 40px;
  /* Отступ от навбара */
  background: linear-gradient(to right, #6a11cb, #2575fc);
  font-family: 'Poppins', sans-serif;
  color: #fff;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

/* 🔷 Общие стили для карточек */
.card {
  width: 100%;
  max-width: 800px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease-in-out;
  margin-bottom: 20px;
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 25px rgba(0, 0, 0, 0.3);
}

/* 🟣 Блок информации о кошельке */
.wallet-info {
  text-align: center;
  font-size: 1rem;
}

/* 🟡 Голосование */
.vote-section {
  text-align: center;
}

/* 🔹 Поля ввода и кнопки */
.input-group {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin-top: 10px;
}

/* 🔷 Поле ввода */
input {
  padding: 12px;
  width: 100%;
  max-width: 300px;
  border: 2px solid rgba(255, 255, 255, 0.5);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.2);
  color: #fff;
  text-align: center;
  font-size: 1.1rem;
  outline: none;
  transition: all 0.3s ease;
}

input::placeholder {
  color: rgba(255, 255, 255, 0.7);
}

input:focus {
  border-color: #fff;
  background: rgba(255, 255, 255, 0.3);
}

/* 🔹 Кнопки */
button {
  background-color: #0d6efd;
  color: white;
  border-radius: 30px;
  font-size: 1.1rem;
  padding: 12px 25px;
  font-weight: bold;
  cursor: pointer;
  border: none;
  transition: all 0.3s ease;
  box-shadow: 0 4px 10px rgba(255, 255, 255, 0.3);
}

button:hover {
  background-color: #0b5ed7;
  box-shadow: 0 6px 15px rgba(255, 255, 255, 0.5);
  transform: scale(1.05);
}

/* 🟢 Список кандидатов */
.candidates-list {
  text-align: center;
  font-size: 1.2rem;


  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease-in-out;
}

.candidates-list:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3);
}

/* 🔹 Стили списка */
ul {
  list-style-type: none;
  padding: 0;
}

li {
  margin-bottom: 10px;
  padding: 15px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  box-shadow: 0 0 5px rgba(255, 255, 255, 0.3);
  font-size: 1rem;
  text-align: left;
}

p {
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.6;
  margin-top: 10px;
  margin-bottom: 10px;
  color: rgba(255, 255, 255, 0.9);
  /* Немного осветленный цвет */
  text-shadow: 0 1px 5px rgba(0, 0, 0, 0.3);
}

h1 {
  margin-bottom: 15px;
}
</style>
