import './assets/styles/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import Aura from '@primevue/themes/aura'
import 'primeicons/primeicons.css'

import App from './App.vue'
import router from './router'
import { i18n } from './plugins/i18n'
import { useUserStore, useUiStore } from './stores'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(i18n)
app.use(router)
app.use(PrimeVue, {
  theme: {
    preset: Aura
  }
})

// Initialize stores after mounting
app.mount('#app')

// Initialize UI store (theme, language)
const uiStore = useUiStore()
uiStore.initialize()

// Initialize user store (restore auth state if token exists)
const userStore = useUserStore()
userStore.initialize()
