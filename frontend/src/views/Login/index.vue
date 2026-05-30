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
        <label class="form-label">登录账号</label>
        <select v-model="loginForm.username" class="form-input" style="font-size:14px;">
          <option value="">-- 请选择账号 --</option>
          <option v-for="u in presetUsers" :key="u.username" :value="u.username">
            {{ u.label }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label class="form-label">登录密码</label>
        <input v-model="loginForm.password" type="password" class="form-input" style="font-size:14px;" placeholder="请输入密码" @keyup.enter="handleLogin" />
      </div>

      <button class="btn btn-primary" style="width:100%;padding:12px;font-size:14px;justify-content:center;" @click="handleLogin" :disabled="loading">
        <span v-if="loading"><i class="fas fa-spinner fa-spin"></i> 登录中...</span>
        <span v-else><i class="fas fa-sign-in-alt"></i> 登 录</span>
      </button>

      <p style="text-align:center;color:#94a3b8;font-size:12px;margin-top:20px;">
        预置账号，初始密码 123456
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore, getDefaultRoute } from '../../store/user'
import { useAppStore } from '../../store/app'
import api from '../../api/request'

const router = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()

const presetUsers = [
  { username: 'dispatcher', label: '中控调度员 (调度中心)' },
  { username: 'gate_clerk', label: '闸口管理员 (闸口管理)' },
  { username: 'qc_op',      label: '岸桥操作员 (岸桥班组)' },
  { username: 'yc_op',      label: '场桥操作员 (场桥班组)' },
  { username: 'admin',      label: '系统管理员 (信息中心)' },
]

const loginForm = ref({ username: '', password: '' })
const loading = ref(false)
const error = ref('')

async function handleLogin() {
  if (!loginForm.value.username) {
    error.value = '请选择登录账号'
    return
  }
  if (!loginForm.value.password) {
    error.value = '请输入密码'
    return
  }
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.post('/auth/login', loginForm.value)
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
