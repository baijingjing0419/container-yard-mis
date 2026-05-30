import { ref } from 'vue'
import { defineStore } from 'pinia'

interface Notification {
  id: number
  text: string
  type: 'warning' | 'alert' | 'info'
}

export const useAppStore = defineStore('app', () => {
  const notifications = ref<Notification[]>([
    { id: 1, text: '堆场A区-12B 集装箱超期滞留', type: 'warning' },
    { id: 2, text: '海侧作业计划延误', type: 'alert' },
    { id: 3, text: '闸口通行拥堵预警', type: 'warning' },
    { id: 4, text: '场桥设备维护提醒', type: 'info' },
    { id: 5, text: '新调度指令待确认', type: 'info' },
  ])
  const sidebarCollapsed = ref(false)

  const unreadCount = ref(notifications.value.length)

  function toggleSidebar() {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  function clearNotification(id: number) {
    notifications.value = notifications.value.filter(n => n.id !== id)
    unreadCount.value = notifications.value.length
  }

  return { notifications, sidebarCollapsed, unreadCount, toggleSidebar, clearNotification }
})
