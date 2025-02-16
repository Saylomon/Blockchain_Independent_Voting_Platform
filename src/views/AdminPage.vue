<template>
  <div class="admin">
    <div class="card wallet-info">
      <h1>Admin Panel</h1>
      <button @click="connectWalletHandler">Connect Wallet</button>

      <div v-if="wallet.address">
        <p><strong>Wallet Address:</strong> {{ wallet.address }}</p>
        <p><strong>Chain:</strong> {{ wallet.chain }}</p>
        <p><strong>Chain ID:</strong> {{ wallet.chainId }}</p>
        <p><strong>Contract Owner:</strong> {{ owner }}</p>
        <p v-if="isOwner"><strong>✅ You are the contract owner.</strong></p>
        <p v-else><strong>⚠️ You are NOT the contract owner.</strong></p>
      </div>
    </div>

    <!-- 🔵 Добавление кандидата -->
    <div class="card vote-section">
      <h1>Add Candidate</h1>
      <div class="input-group">
        <input v-model="newCandidate" placeholder="Candidate Name" />
        <button @click="addCandidateHandler">Add</button>
      </div>
    </div>

    <!-- ⏳ Установка времени голосования -->
    <div class="card vote-timer">
      <h1>Set Voting Duration</h1>
      <div class="select-group">
        <select v-model="selectedDuration">
          <option value="160">2 minutes</option>
          <option value="1840">30 minutes</option>
          <option value="3640">1 hour</option>
          <option value="7240">2 hours</option>
          <option value="14440">4 hours</option>
          <option value="86440">1 day</option>
        </select>
      </div>
      <button class="select-btn" @click="calculateTargetTime">Set Voting Time</button>
      <p v-if="calculatedEndTime">Target End Time: {{ calculatedEndTime }}</p>
    </div>

    <!-- 🔴 Управление голосованием -->
    <div class="card vote-control">
      <h1>Control Voting</h1>
      <div class="input-group">
        <input v-model="startTime" placeholder="Start Time (Unix Timestamp)" />
        <input v-model="endTime" placeholder="End Time (Unix Timestamp)" />
      </div>
      <div class="btn-group">
        <button @click="startVotingHandler">Start</button>
        <button @click="endVotingHandler">End</button>
      </div>
    </div>

    <!-- ⚪ Получить текущее время -->
    <div class="card">
      <h1>Get Current Time</h1>
      <button @click="getTimeHandler">Fetch Time</button>
      <div v-if="currentTime">
        <h3>
          Current Time: <span ref="currentTime">{{ currentTime }}</span>
          <button class="copyBtn" @click="copyToClipboard">Copy</button>
        </h3>
      </div>
    </div>

    <!-- 🏆 Победитель -->
    <div class="card candidates-list">
      <h1>Get Winner</h1>
      <button @click="getWinnerHandler">Show Winner</button>
      <div v-if="winner">
        <p><strong>Winner ID:</strong> {{ winner.candidateId }}</p>
        <p><strong>Name:</strong> {{ winner.candidateName }}</p>
        <p><strong>Votes:</strong> {{ winner.voteCount }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState, mapActions } from 'vuex';

export default {
  data() {
    return {
      startTime: '',
      endTime: '',
      newCandidate: '',
      selectedDuration: 3600,
      calculatedEndTime: null
    };
  },
  computed: {
    ...mapState(['wallet', 'votingStatus', 'winner', 'owner', 'currentTime']),
    isOwner() {
      return this.wallet.address && this.owner && this.wallet.address.toLowerCase() === this.owner.toLowerCase();
    }
  },
  methods: {
    ...mapActions(['connectWallet', 'startVoting', 'endVoting', 'getWinner', 'getTime', 'addCandidate', 'getVoteStatus', 'getOwner']),

    async connectWalletHandler() {
      try {
        await this.connectWallet();
        await this.getOwner();
      } catch (error) {
        alert(`Error connecting wallet: ${error.message}`);
      }
    },

    async startVotingHandler() {
      if (!this.isOwner) {
        alert("⚠️ Error: You are not the contract owner.");
        return;
      }

      try {
        if (!this.startTime || !this.endTime) {
          alert("❌ Please enter valid start and end times.");
          return;
        }

        const startTime = parseInt(this.startTime);
        const endTime = parseInt(this.endTime);

        if (startTime >= endTime) {
          alert("❌ Start time must be before end time.");
          return;
        }

        await this.getVoteStatus();
        if (this.votingEnded) {
          alert("❌ Voting has already ended. Cannot start again.");
          return;
        }

        const tx = await this.startVoting({ startTime, endTime });
        await tx.wait();

        alert("✅ Voting successfully started!");
        this.startTime = '';
        this.endTime = '';
      } catch (error) {
        console.error("Error starting voting:", error);
        alert(`⚠️ Error: ${error.message}`);
      }
    },

    async endVotingHandler() {
      if (!this.isOwner) {
        alert("⚠️ Error: You are not the contract owner.");
        return;
      }

      try {
        await this.endVoting();
        alert("✅ Voting successfully ended!");
      } catch (error) {
        console.log(`Error ending voting: ${error.message}`);
      }
    },

    async getWinnerHandler() {
      try {
        await this.getWinner();
      } catch (error) {
        console.log(`Error getting winner: ${error.message}`);
      }
    },

    async getTimeHandler() {
      try {
        await this.getTime();
      } catch (error) {
        console.error('Error fetching time:', error);
      }
    },

    copyToClipboard() {
      navigator.clipboard.writeText(this.$refs.currentTime.textContent).then(() => {
        alert('✅ Time copied to clipboard!');
      });
    },

    async addCandidateHandler() {
      if (!this.isOwner) {
        alert("⚠️ Error: You are not the contract owner.");
        return;
      }
      try {
        await this.addCandidate(this.newCandidate);
        this.newCandidate = '';
      } catch (error) {
        alert(`Error adding candidate: ${error.message}`);
      }
    },

    async calculateTargetTime() {
      try {
        await this.getTime(); // 🔥 Запрос текущего времени перед расчетами

        const now = parseInt(this.currentTime); // Получаем текущее время
        this.startTime = now + 40; // Время старта через 40 секунд
        this.endTime = now + parseInt(this.selectedDuration); // Время окончания через выбранное время

        this.calculatedEndTime = this.endTime; // Отображение рассчитанного времени

        alert(`✅ Voting start time: ${this.startTime}, end time: ${this.endTime}`);
      } catch (error) {
        console.error("Error calculating target time:", error);
      }
    }
  }
};
</script>



<style scoped>
/* 🌟 Глобальные стили */
.admin {
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

.select-btn {
  margin-top: 15px;
}

/* 🏆 Блок победителя */
.candidates-list {
  text-align: center;
  font-size: 1.2rem;
}

/* 📜 Стили списка */
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

h3 {
  margin-top: 15px;
}

.btn-group {
  margin: 20px;
  gap: 15px;
  display: flex;
  justify-content: center;
}

.copyBtn {
  margin-left: 15px;
}

/* 🔷 Стили для выпадающего списка (select) */
.select-group select {
  padding: 12px;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  border: 2px solid rgba(255, 255, 255, 0.5);
  background: rgba(255, 255, 255, 0.2);
  color: #fff;
  outline: none;
  transition: all 0.3s ease;
  width: 100%;
  max-width: 300px;
  text-align: center;
}

/* При наведении */
.select-group select:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* При фокусе */
.select-group select:focus {
  border-color: #fff;
  background: rgba(255, 255, 255, 0.3);
}

/* Стилизация стрелочки select */
.select-group select::-ms-expand {
  display: none;
}

.select-group select option {
  background: #6a11cb;
  color: white;
  font-size: 1rem;
  padding: 10px;
}
</style>