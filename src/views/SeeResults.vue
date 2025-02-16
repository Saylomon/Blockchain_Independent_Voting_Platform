<template>
  <div class="results">
    <!-- 🟣 Блок информации о кошельке -->
    <div class="card wallet-info">
      <h1>Voting Results</h1>
      <button @click="connectWalletHandler" class="btn-custom">Connect Wallet</button>

      <div v-if="wallet.address">
        <p><strong>Wallet Address:</strong> {{ wallet.address }}</p>
        <p><strong>Chain:</strong> {{ wallet.chain }}</p>
        <p><strong>Chain ID:</strong> {{ wallet.chainId }}</p>
      </div>
    </div>

    <!-- 🔵 Результаты выборов -->
    <div v-if="hasElectionResult" class="card results-card">
      <h1>Results</h1>
      <p><strong>Candidate ID:</strong> {{ electionResult?.candidateId ?? 'N/A' }}</p>
      <p><strong>Candidate Name:</strong> {{ electionResult?.candidateName ?? 'N/A' }}</p>
      <p><strong>Vote Count:</strong> {{ electionResult?.voteCount ?? 'N/A' }}</p>
    </div>

    <!-- 🛑 Нет результатов -->
    <div v-else class="no-results">
      <p v-if="loading">🔄 Loading results...</p>
      <p v-else>No results available.</p>
    </div>
  </div>
</template>

<script>
import { mapState, mapActions } from 'vuex';

export default {
  data() {
    return {
      loading: true, // 🕒 Флаг загрузки
    };
  },
  computed: {
    ...mapState(['wallet', 'electionResult']),
    hasElectionResult() {
      return this.electionResult && this.electionResult.candidateId !== undefined && this.electionResult.candidateId !== 0;
    }
  },
  methods: {
    ...mapActions(['connectWallet', 'getWinner']),
    async connectWalletHandler() {
      try {
        await this.connectWallet();
        await this.loadResults();
      } catch (error) {
        console.error("Error connecting wallet and fetching results:", error);
      }
    },
    async loadResults() {
      try {
        this.loading = true;
        await this.getWinner();
      } catch (error) {
        console.error("Error fetching election results:", error);
      } finally {
        this.loading = false;
      }
    }
  },
  async mounted() {
    if (this.wallet.address) {
      await this.loadResults();
    } else {
      this.loading = false;
    }
  }
};
</script>

<style scoped>
/* 🌟 Глобальные стили */
.results {
  padding: 140px 20px 40px;
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
}

/* 🔵 Результаты */
.results-card {
  text-align: center;
  font-size: 1.2rem;
}

/* 🔹 Кнопки */
.btn-custom {
  background-color: #0d6efd;
  color: white;
  border-radius: 30px;
  font-size: 1.2rem;
  padding: 12px 25px;
  font-weight: bold;
  cursor: pointer;
  border: none;
  transition: all 0.3s ease;
  box-shadow: 0 4px 10px rgba(255, 255, 255, 0.3);
}

.btn-custom:hover {
  background-color: #0b5ed7;
  box-shadow: 0 6px 15px rgba(255, 255, 255, 0.5);
  transform: scale(1.05);
}

/* 📜 Нет результатов */
.no-results {
  font-size: 1.2rem;
  padding: 15px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  box-shadow: 0 0 5px rgba(255, 255, 255, 0.3);
  margin-top: 15px;
  font-weight: bold;
}

/* 📜 Обычный текст */
p {
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.6;
  margin-top: 10px;
  margin-bottom: 10px;
  color: rgba(255, 255, 255, 0.9); /* Немного осветленный цвет */
  text-shadow: 0 1px 5px rgba(0, 0, 0, 0.3);
}

h1 {
  margin-bottom: 15px;
}
</style>
