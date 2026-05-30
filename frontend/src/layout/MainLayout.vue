<template>
  <aside class="sidebar">
    <div class="sidebar-header">
      <div style="font-size: 32px; margin-bottom: 8px;"><i class="fas fa-ship"></i></div>
      <h1>集装箱码头堆场MIS</h1>
      <p>Container Terminal Yard Management</p>
    </div>
    <div class="nav-menu">
      <div class="nav-section-title">总览</div>
      <router-link to="/dashboard" class="nav-item">
        <i class="fas fa-chart-line"></i>
        <span>运营总览 Dashboard</span>
      </router-link>

      <div class="nav-section-title">海侧作业管理</div>
      <router-link to="/sea/inbound" class="nav-item">
        <i class="fas fa-arrow-down"></i>
        <span>海侧进箱作业</span>
      </router-link>
      <router-link to="/sea/outbound" class="nav-item">
        <i class="fas fa-arrow-up"></i>
        <span>海侧出场作业</span>
      </router-link>
      <router-link to="/sea/plan" class="nav-item">
        <i class="fas fa-calendar-alt"></i>
        <span>海侧作业计划</span>
      </router-link>

      <div class="nav-section-title">陆侧作业管理</div>
      <router-link to="/land/inbound" class="nav-item">
        <i class="fas fa-truck-loading"></i>
        <span>陆侧进箱作业</span>
      </router-link>
      <router-link to="/land/outbound" class="nav-item">
        <i class="fas fa-truck-moving"></i>
        <span>陆侧出场作业</span>
      </router-link>
      <router-link to="/land/plan" class="nav-item">
        <i class="fas fa-clipboard-list"></i>
        <span>陆侧作业计划</span>
      </router-link>

      <div class="nav-section-title">场内管理</div>
      <router-link to="/yard/storage" class="nav-item">
        <i class="fas fa-warehouse"></i>
        <span>集装箱堆存管理</span>
      </router-link>
      <router-link to="/yard/move" class="nav-item">
        <i class="fas fa-exchange-alt"></i>
        <span>场内调箱作业</span>
      </router-link>
      <router-link to="/dispatch" class="nav-item">
        <i class="fas fa-broadcast-tower"></i>
        <span>中控调度指令</span>
      </router-link>

      <div class="nav-section-title">查询统计</div>
      <router-link to="/query" class="nav-item">
        <i class="fas fa-search"></i>
        <span>箱量/状态查询</span>
      </router-link>
      <router-link to="/statistics" class="nav-item">
        <i class="fas fa-chart-bar"></i>
        <span>作业效率统计</span>
      </router-link>
      <router-link to="/reports" class="nav-item">
        <i class="fas fa-file-alt"></i>
        <span>报表中心</span>
      </router-link>
    </div>
  </aside>

  <main class="main-content">
    <div class="top-bar">
      <div class="breadcrumb">
        <i class="fas fa-home" style="margin-right: 8px;"></i>
        首页 <span style="margin: 0 8px; color: #cbd5e1;">/</span>
        <span>{{ pageTitle }}</span>
      </div>
      <div class="user-info">
        <div class="notification-btn" @click="appStore.toggleNotificationPanel()">
          <i class="fas fa-bell" style="color: #64748b;"></i>
          <span v-if="appStore.unreadCount" class="badge">{{ appStore.unreadCount }}</span>
        </div>
        <div style="text-align: right;">
          <div style="font-size: 14px; font-weight: 600; color: #1e293b;">{{ userStore.displayName }}</div>
          <div style="font-size: 12px; color: #94a3b8;">{{ userStore.department }} - {{ userStore.shift }}</div>
        </div>
        <div class="user-avatar">{{ userStore.realName.charAt(0) }}</div>
      </div>

      <div v-if="appStore.showNotificationPanel" class="notification-panel">
        <div class="notification-panel-header">
          <span>通知中心</span>
          <button class="btn btn-sm btn-secondary" @click="appStore.fetchNotifications()">
            <i class="fas fa-sync-alt"></i>
          </button>
        </div>
        <div v-if="!appStore.notifications.length" style="text-align:center;padding:30px;color:#94a3b8;font-size:13px;">暂无通知</div>
        <div v-for="n in appStore.notifications" :key="n.id" class="notification-item" @click="appStore.clearNotification(n.id)">
          <div :class="['notification-dot', n.type]"></div>
          <div class="notification-text">{{ n.text }}</div>
          <i class="fas fa-times" style="color:#cbd5e1;font-size:10px;cursor:pointer;"></i>
        </div>
      </div>
      <div v-if="appStore.showNotificationPanel" class="notification-backdrop" @click="appStore.showNotificationPanel = false"></div>
    </div>

    <div class="content-area">
      <router-view />
    </div>

    <div class="toast-container">
      <div v-for="t in appStore.toasts" :key="t.id" :class="['toast', `toast-${t.type}`]">
        <i :class="t.type === 'success' ? 'fas fa-check-circle' : t.type === 'error' ? 'fas fa-exclamation-circle' : 'fas fa-info-circle'"></i>
        {{ t.message }}
      </div>
    </div>
  </main>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '../store/user'
import { useAppStore } from '../store/app'

const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()

const pageTitle = computed(() => route.meta?.title || '运营总览')

onMounted(() => { appStore.fetchNotifications() })
</script>
