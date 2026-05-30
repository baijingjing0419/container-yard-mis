<template>
  <div class="login-page">
    <div class="login-card">
      <div style="text-align:center;margin-bottom:24px;">
        <div style="font-size:40px;margin-bottom:8px;"><i class="fas fa-key" style="color:#1e40af;"></i></div>
        <h2 style="color:#1e293b;margin:0 0 4px;">首次登录 · 设置密码</h2>
        <p style="color:#94a3b8;font-size:13px;margin:0;">{{ employeeName }} ({{ employeeId }})</p>
      </div>

      <div v-if="error" class="alert alert-warning" style="margin-bottom:16px;">
        <i class="fas fa-exclamation-triangle"></i> {{ error }}
      </div>

      <div class="form-group">
        <label class="form-label">新密码</label>
        <input v-model="password" type="password" class="form-input" placeholder="请输入新密码" @keyup.enter="handleSubmit" />
      </div>

      <div class="form-group">
        <label class="form-label">确认密码</label>
        <input v-model="confirmPassword" type="password" class="form-input" placeholder="请再次输入密码" @keyup.enter="handleSubmit" />
      </div>

      <button class="btn btn-primary" style="width:100%;padding:12px;font-size:14px;justify-content:center;" @click="handleSubmit" :disabled="loading">
        <span v-if="loading"><i class="fas fa-spinner fa-spin"></i> 设置中...</span>
        <span v-else>设 置 密 码 并 登 录</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore, getDefaultRoute } from '../../store/user'
import api from '../../api/request'

const router = useRouter()
const userStore = useUserStore()

const employeeId = ref('')
const employeeName = ref('')
const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')

onMounted(() => {
  const state = history.state as any
  if (!state?.employeeId) {
    router.replace('/login')
    return
  }
  employeeId.value = state.employeeId
  employeeName.value = state.realName || state.employeeId
})

async function handleSubmit() {
  if (!password.value) { error.value = '请输入新密码'; return }
  if (password.value !== confirmPassword.value) { error.value = '两次密码不一致'; return }
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.post('/auth/setup-password', {
      employee_id: employeeId.value,
      password: password.value,
    })
    userStore.login({
      username: data.username,
      realName: data.real_name || data.username,
      role: data.role,
      department: data.department || '',
      accessToken: data.access_token,
    })
    router.replace(getDefaultRoute(data.role))
  } catch (e: any) {
    error.value = e?.response?.data?.detail || '设置失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #06b6d4 100%); }
.login-card { background: #fff; border-radius: 16px; padding: 40px; width: 420px; max-width: 90vw; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
</style>
