<template>
  <div class="login-page">
    <div class="login-card">
      <div style="text-align:center;margin-bottom:32px;">
        <div style="font-size:40px;margin-bottom:12px;"><i class="fas fa-ship" style="color:#1e40af;"></i></div>
        <h2 style="color:#1e293b;margin:0 0 4px;">集装箱码头堆场MIS</h2>
        <p style="color:#94a3b8;font-size:13px;margin:0;">Container Terminal Yard Management</p>
      </div>

      <div v-if="error" class="alert alert-warning" style="margin-bottom:16px;">
        <i class="fas fa-exclamation-triangle"></i> {{ error }}
      </div>

      <div class="form-group">
        <label class="form-label">工号</label>
        <input v-model="loginForm.user_id" class="form-input" style="font-size:14px;" placeholder="请输入工号" @keyup.enter="handleLogin" />
      </div>

      <div class="form-group">
        <label class="form-label">密码</label>
        <input v-model="loginForm.password" type="password" class="form-input" style="font-size:14px;" placeholder="请输入密码" @keyup.enter="handleLogin" />
      </div>

      <button class="btn btn-primary" style="width:100%;padding:12px;font-size:14px;justify-content:center;" @click="handleLogin" :disabled="loading">
        <span v-if="loading"><i class="fas fa-spinner fa-spin"></i> 登录中...</span>
        <span v-else><i class="fas fa-sign-in-alt"></i> 登 录</span>
      </button>

      <div style="margin-top:24px;padding-top:16px;border-top:1px solid #e2e8f0;text-align:center;">
        <button class="btn btn-secondary" style="width:100%;padding:10px;font-size:13px;justify-content:center;" @click="devLogin">
          <i class="fas fa-code"></i> 开发者入口（直接进入）
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore, getDefaultRoute } from '../../store/user'
import { useAppStore } from '../../store/app'
import api from '../../api/request'

const router = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()

const loginForm = ref({ user_id: '', password: '' })
const loading = ref(false)
const error = ref('')

function devLogin() {
  userStore.login({
    username: 'admin',
    realName: '管理员',
    role: 'admin',
    department: '信息中心',
    accessToken: 'dev-token',
  })
  router.push('/dashboard')
}

async function handleLogin() {
  if (!loginForm.value.user_id) {
    error.value = '请输入工号'
    return
  }
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.post('/auth/login', loginForm.value)
    if (data.needs_password_setup) {
      router.push('/first-login', { state: { employeeId: data.user_id, realName: data.real_name } })
      return
    }
    userStore.login({
      username: data.username,
      realName: data.real_name || data.username,
      role: data.role,
      department: data.department || '',
      accessToken: data.access_token,
    })
    appStore.fetchNotifications()
    router.push(getDefaultRoute(data.role))
  } catch (e) {
    error.value = e?.response?.data?.detail || '登录失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #06b6d4 100%); }
.login-card { background: #fff; border-radius: 16px; padding: 40px; width: 400px; max-width: 90vw; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
</style>
