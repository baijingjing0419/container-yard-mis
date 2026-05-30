import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

const ROLE_LABELS: Record<string, string> = {
  dispatcher: '中控调度员', gate_clerk: '闸口管理员', qc_op: '岸桥操作员', yc_op: '场桥操作员', admin: '系统管理员',
}
const ROLE_DEPTS: Record<string, string> = {
  dispatcher: '调度中心', gate_clerk: '闸口管理', qc_op: '岸桥班组', yc_op: '场桥班组', admin: '信息中心',
}

export const useUserStore = defineStore('user', () => {
  const username = ref('')
  const realName = ref('')
  const role = ref('')
  const department = ref('')
  const loggedIn = ref(false)

  const displayName = computed(() => realName.value || username.value || '未登录')
  const roleLabel = computed(() => ROLE_LABELS[role.value] || role.value)
  const shift = ref('当班')

  function login(user: { username: string; realName?: string; role: string; department?: string }) {
    username.value = user.username
    realName.value = user.realName || user.username
    role.value = user.role
    department.value = user.department || ROLE_DEPTS[user.role] || ''
    loggedIn.value = true
    localStorage.setItem('yard_user', JSON.stringify({
      username: user.username, realName: user.realName, role: user.role, department: user.department,
    }))
  }

  function restoreSession() {
    const saved = localStorage.getItem('yard_user')
    if (saved) {
      try {
        const u = JSON.parse(saved)
        login(u)
      } catch { /* ignore */ }
    }
  }

  function logout() {
    username.value = ''; realName.value = ''; role.value = ''; department.value = ''
    loggedIn.value = false
    localStorage.removeItem('yard_user')
  }

  return { username, realName, role, department, shift, loggedIn, displayName, roleLabel, login, restoreSession, logout }
})

export function getDefaultRoute(role: string): string {
  const map: Record<string, string> = {
    admin: '/dashboard',
    dispatcher: '/dispatch',
    gate_clerk: '/land/inbound',
    qc_op: '/sea/inbound',
    yc_op: '/yard/move',
  }
  return map[role] || '/dashboard'
}
