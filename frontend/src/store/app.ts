import { ref } from 'vue'
import { defineStore } from 'pinia'
import api from '../api/request'

interface Notification {
  id: number
  text: string
  type: 'warning' | 'alert' | 'info'
}

interface Toast {
  id: number
  message: string
  type: 'success' | 'error' | 'info'
}

let toastId = 0

export const useAppStore = defineStore('app', () => {
  const notifications = ref<Notification[]>([])
  const sidebarCollapsed = ref(false)
  const unreadCount = ref(0)
  const toasts = ref<Toast[]>([])
  const showNotificationPanel = ref(false)

  function toggleSidebar() {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  function toggleNotificationPanel() {
    showNotificationPanel.value = !showNotificationPanel.value
  }

  function clearNotification(id: number) {
    notifications.value = notifications.value.filter(n => n.id !== id)
    unreadCount.value = notifications.value.length
  }

  async function fetchNotifications() {
    try {
      const { data } = await api.get('/alerts', { params: { is_resolved: false, page_size: 10 } })
      const items = data?.items || []
      notifications.value = items.map((a: any) => ({
        id: a.alert_id,
        text: a.alert_title || '告警',
        type: a.alert_level === 'critical' ? 'alert' as const : a.alert_level === 'warning' ? 'warning' as const : 'info' as const,
      }))
      unreadCount.value = notifications.value.length
    } catch {
      notifications.value = []
      unreadCount.value = 0
    }
  }

  function showToast(message: string, type: Toast['type'] = 'info') {
    const id = ++toastId
    toasts.value.push({ id, message, type })
    setTimeout(() => { toasts.value = toasts.value.filter(t => t.id !== id) }, 3000)
  }

  return {
    notifications, sidebarCollapsed, unreadCount, toasts, showNotificationPanel,
    toggleSidebar, toggleNotificationPanel, clearNotification, fetchNotifications, showToast,
  }
})
