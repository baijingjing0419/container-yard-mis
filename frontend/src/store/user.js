import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', () => {
  const username = ref('dispatcher')
  const realName = ref('中控调度员')
  const role = ref('dispatcher')
  const department = ref('调度中心')
  const shift = ref('当班')

  const displayName = computed(() => realName.value || username.value)
  const roleLabel = computed(() => {
    const map = { dispatcher: '中控调度员', gate_clerk: '闸口管理员', yard_op: '堆场管理员', admin: '系统管理员' }
    return map[role.value] || role.value
  })

  function setUser(user) {
    if (user.username) username.value = user.username
    if (user.real_name) realName.value = user.real_name
    if (user.role) role.value = user.role
    if (user.department) department.value = user.department
  }

  return { username, realName, role, department, shift, displayName, roleLabel, setUser }
})
