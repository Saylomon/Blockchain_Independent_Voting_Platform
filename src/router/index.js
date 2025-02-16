import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'
import AdminPage from '@/views/AdminPage.vue'
import SeeResults from '@/views/SeeResults.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/admin',
    name: 'adminPage',
    component: AdminPage
  },
  {
    path: '/results',
    name: 'SeeResultPage',
    component: SeeResults
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
