<template>
  <div class="setup-page">
    <div class="setup-card">
      <div style="text-align:center;margin-bottom:28px;">
        <div style="font-size:48px;margin-bottom:12px;"><i class="fas fa-cogs" style="color:#1e40af;"></i></div>
        <h2 style="color:#1e293b;margin:0 0 6px;">系统初始化向导</h2>
        <p style="color:#94a3b8;font-size:14px;margin:0;">首次使用前请完成以下配置</p>
      </div>

      <!-- 步骤指示器 -->
      <div class="steps-bar">
        <div class="step-dot" :class="{ active: step === 1, done: step > 1 }">1</div>
        <div class="step-line" :class="{ done: step > 1 }"></div>
        <div class="step-dot" :class="{ active: step === 2, done: step > 2 }">2</div>
      </div>

      <!-- Step 1: 创建管理员 -->
      <div v-if="step === 1">
        <div class="step-title"><i class="fas fa-user-shield"></i> 创建管理员账号</div>
        <p class="step-desc">系统尚未创建管理员，请设置第一个管理员账号。</p>

        <div v-if="error" class="alert alert-warning"><i class="fas fa-exclamation-triangle"></i> {{ error }}</div>

        <div class="form-group"><label class="form-label">工号</label><input v-model="form.user_id" class="form-input" placeholder="管理员工号" /></div>
        <div class="form-group"><label class="form-label">姓名</label><input v-model="form.real_name" class="form-input" placeholder="管理员姓名" /></div>
        <div class="form-group"><label class="form-label">密码</label><input v-model="form.password" type="password" class="form-input" placeholder="设置管理员密码" /></div>

        <button class="btn btn-primary" style="width:100%;padding:12px;justify-content:center;" @click="createAdmin" :disabled="loading">
          <span v-if="loading"><i class="fas fa-spinner fa-spin"></i> 创建中...</span>
          <span v-else>创建管理员并登录</span>
        </button>
      </div>

      <!-- Step 2: 堆场检测 -->
      <div v-if="step === 2">
        <div class="step-title"><i class="fas fa-warehouse"></i> 堆场布局配置</div>
        <p class="step-desc">堆场区域和箱位由 schema.sql 自动初始化，无需手动导入。</p>

        <div v-if="yardOk" class="alert alert-success">
          <i class="fas fa-check-circle"></i> 堆场布局已就绪（{{ zoneCount }} 个区域）
        </div>
        <div v-else class="alert alert-warning" style="margin-bottom:16px;">
          <i class="fas fa-exclamation-triangle"></i> 堆场数据未检测到，请重建容器以触发 schema.sql 初始化。
        </div>

        <div style="display:flex;gap:12px;margin-top:16px;">
          <button v-if="!yardOk" class="btn btn-secondary" style="flex:1;padding:12px;justify-content:center;" @click="checkYard">
            <i class="fas fa-sync-alt"></i> 重新检测
          </button>
          <button class="btn btn-primary" style="flex:1;padding:12px;justify-content:center;" @click="finishSetup">
            <i class="fas fa-check"></i> 进入系统
          </button>
        </div>
      </div>
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

const step = ref(1)
const loading = ref(false)
const error = ref('')
const yardOk = ref(false)
const zoneCount = ref(0)

const form = ref({ user_id: '', real_name: '', password: '' })

onMounted(async () => {
  try {
    const r = await api.get('/system/status')
    if (!r.data.setup_required) { router.replace('/dashboard'); return }
    yardOk.value = r.data.yard_configured
    if (!r.data.admin_exists) step.value = 1
    else step.value = 2
  } catch {}
})

async function createAdmin() {
  if (!form.value.user_id) { error.value = '请输入工号'; return }
  if (!form.value.real_name) { error.value = '请输入姓名'; return }
  if (!form.value.password) { error.value = '请输入密码'; return }
  loading.value = true; error.value = ''
  try {
    const { data } = await api.post('/auth/setup-admin', {
      user_id: form.value.user_id,
      real_name: form.value.real_name,
      password: form.value.password,
    })
    userStore.login({
      username: data.username,
      realName: data.real_name || data.username,
      role: data.role,
      department: data.department || '',
      accessToken: data.access_token,
    })
    step.value = 2
  } catch (e: any) {
    error.value = e?.response?.data?.detail || '创建失败'
  } finally { loading.value = false }
}

async function checkYard() {
  try { const r = await api.get('/system/status'); yardOk.value = r.data.yard_configured } catch {}
}

function finishSetup() {
  const path = getDefaultRoute(userStore.role || 'admin')
  router.replace(path).catch(() => router.push('/dashboard'))
}
</script>

<style scoped>
.setup-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #1e3a5f 0%, #1e40af 50%, #0d9488 100%); }
.setup-card { background: #fff; border-radius: 16px; padding: 40px; width: 480px; max-width: 90vw; box-shadow: 0 20px 60px rgba(0,0,0,0.25); }
.steps-bar { display: flex; align-items: center; justify-content: center; margin-bottom: 28px; }
.step-dot { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; background: #e2e8f0; color: #94a3b8; transition: all .3s; }
.step-dot.active { background: #1e40af; color: #fff; }
.step-dot.done { background: #10b981; color: #fff; }
.step-line { flex: 1; height: 3px; background: #e2e8f0; margin: 0 12px; transition: all .3s; }
.step-line.done { background: #10b981; }
.step-title { font-size: 16px; font-weight: 600; color: #1e293b; margin-bottom: 4px; }
.step-desc { color: #94a3b8; font-size: 13px; margin-bottom: 20px; }
.alert-success { background: #d1fae5; color: #065f46; padding: 12px 16px; border-radius: 8px; font-size: 13px; }
</style>
