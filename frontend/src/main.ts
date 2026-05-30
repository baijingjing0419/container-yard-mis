import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useAppStore } from './store/app'
import './index.css'

const app = createApp(App)
const pinia = createPinia()
app.use(pinia)
app.use(router)
app.mount('#app')

// 挂载 appStore 到 window 供 axios 拦截器在 409 时使用 Toast
;(window as any).__appStore = useAppStore()
