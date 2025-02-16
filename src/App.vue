<template>
  <div id="app">
    <nav>
      <router-link to="/">Home</router-link>
      <router-link to="/admin">Admin</router-link>
      <router-link to="/results">Show Results</router-link>
    </nav>
    <router-view></router-view>
  </div>
</template>

<style>
/* Reset Margins & Padding */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Ensure Full Width & Height */
html, body, #app {
  width: 100%;
  height: 100%;
  overflow-x: hidden;
  font-family: 'Poppins', 'Montserrat', sans-serif;
}

/* Navbar */
nav {
  width: 100%;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  padding: 15px 0;
  position: fixed;
  top: 0;
  z-index: 1000;
  display: flex;
  justify-content: center;
  transition: background 0.3s ease-in-out;
}

/* Navigation Links */
nav a {
  font-weight: bold;
  color: #6a11cb !important;
  margin: 0 20px;
  text-decoration: none;
  font-size: 1.4rem;
  padding: 12px 24px;
  border-radius: 8px;
  transition: color 0.3s, background 0.3s, box-shadow 0.3s;
}

/* Hover Effect */
nav a:hover {
  color: #2575fc !important;
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0 0 8px rgba(255, 255, 255, 0.5);
}

/* Active Link */
nav a.router-link-exact-active {
  color: #fff !important;
  background: #2575fc;
  box-shadow: 0 0 8px rgba(13, 110, 253, 0.5);
}

/* Main Content Area */
.content {
  padding: 100px 20px 20px;
  flex-grow: 1;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  animation: fadeIn 1s ease-in-out;
}

/* Fade-in Animation */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>




