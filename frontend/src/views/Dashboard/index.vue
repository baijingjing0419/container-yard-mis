<template>
  <div class="fade-in">
    <div class="page-title">运营总览 Dashboard</div>
    <div class="page-subtitle">实时监控码头堆场运营状态与关键指标</div>

    <div v-if="error" class="alert alert-warning" style="margin-bottom: 16px;">
      <i class="fas fa-exclamation-triangle"></i> 部分数据加载失败，请刷新重试
    </div>

    <div class="stats-grid">
      <div class="stat-card" v-for="card in statCards" :key="card.label">
        <div class="stat-header">
          <div>
            <div class="stat-value" v-if="!loading">{{ card.value }}</div>
            <div class="stat-value" v-else style="color:#cbd5e1;">--</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
          <div class="stat-icon" :class="card.color"><i :class="card.icon"></i></div>
        </div>
        <div class="stat-change" :class="card.trend >= 0 ? 'up' : 'down'">
          <i :class="card.trend >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i> {{ card.sub }}
        </div>
      </div>
    </div>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
      <div class="card">
        <div class="card-header">
          <div class="card-title"><i class="fas fa-chart-area" style="margin-right: 8px; color: #3b82f6;"></i>24小时作业趋势</div>
        </div>
        <div class="card-body">
          <div v-if="trendLoading" style="text-align:center;padding:60px;color:#94a3b8;">加载中...</div>
          <div class="chart-container" v-show="!trendLoading">
            <canvas ref="trendCanvas"></canvas>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-header">
          <div class="card-title"><i class="fas fa-bell" style="margin-right: 8px; color: #f97316;"></i>实时告警</div>
          <span v-if="appStore.unreadCount" class="status-badge warning"><span class="dot red"></span>{{ appStore.unreadCount }} 条未处理</span>
          <span v-else class="status-badge completed">暂无告警</span>
        </div>
        <div class="card-body">
          <div v-if="!appStore.notifications.length" style="text-align:center;padding:40px;color:#94a3b8;">当前无未处理告警</div>
          <div class="timeline" v-else>
            <div class="timeline-item" v-for="n in appStore.notifications" :key="n.id">
              <div class="timeline-dot" :style="{ background: n.type === 'alert' ? '#ef4444' : n.type === 'warning' ? '#f97316' : '#3b82f6', boxShadow: `0 0 0 2px ${n.type === 'alert' ? '#ef4444' : n.type === 'warning' ? '#f97316' : '#3b82f6'}` }"></div>
              <div class="timeline-time">实时</div>
              <div class="timeline-title">{{ n.text }}</div>
              <div class="timeline-content">来自系统告警</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div style="margin-top: 20px;">
      <div class="card">
        <div class="card-header">
          <div class="card-title"><i class="fas fa-th" style="margin-right: 8px; color: #06b6d4;"></i>堆场实时状态图</div>
          <div style="display: flex; gap: 15px; font-size: 12px;">
            <span><span style="display: inline-block; width: 12px; height: 12px; background: rgba(59,130,246,0.3); border: 2px solid #3b82f6; border-radius: 3px; vertical-align: middle; margin-right: 4px;"></span>已占用</span>
            <span><span style="display: inline-block; width: 12px; height: 12px; background: #f1f5f9; border: 2px solid #cbd5e1; border-radius: 3px; vertical-align: middle; margin-right: 4px;"></span>空闲</span>
            <span><span style="display: inline-block; width: 12px; height: 12px; background: rgba(249,115,22,0.3); border: 2px solid #f97316; border-radius: 3px; vertical-align: middle; margin-right: 4px;"></span>预留</span>
            <span><span style="display: inline-block; width: 12px; height: 12px; background: rgba(239,68,68,0.3); border: 2px solid #ef4444; border-radius: 3px; vertical-align: middle; margin-right: 4px;"></span>维护</span>
          </div>
        </div>
        <div class="card-body">
          <div v-if="yardLoading" style="text-align:center;padding:40px;color:#94a3b8;">加载中...</div>
          <div v-else style="display: flex; gap: 20px;">
            <div style="flex: 1;" v-for="zone in yardZones" :key="zone.zone_id">
              <div style="font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #1e40af;">
                {{ zone.zone_name || (zone.zone_id + '区') }}
              </div>
              <div class="yard-map" :ref="el => setYardRef(zone.zone_id, el)"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import Chart from 'chart.js/auto'
import api from '../../api/request'
import { getInventoryList } from '../../api/yardInventory'
import { getDispatchOrderList } from '../../api/dispatchOrder'
import { getOperationList } from '../../api/yardOperation'
import { getSeaInboundList } from '../../api/seaInbound'
import { getLandInboundList } from '../../api/landInbound'
import { useAppStore } from '../../store/app'

const loading = ref(true)
const error = ref(false)
const trendLoading = ref(true)
const yardLoading = ref(true)

const yardZones = ref([])
const yardSlotMap = reactive({})
const yardRefs = reactive({})
const trendCanvas = ref(null)
const appStore = useAppStore()
let chartInstance = null

const statCards = reactive([
  { label: '场内集装箱总量', value: '--', color: 'blue', icon: 'fas fa-box', trend: 0, sub: '加载中...' },
  { label: '今日海侧作业量', value: '--', color: 'cyan', icon: 'fas fa-ship', trend: 0, sub: '加载中...' },
  { label: '今日陆侧作业量', value: '--', color: 'green', icon: 'fas fa-truck', trend: 0, sub: '加载中...' },
  { label: '堆场利用率', value: '--', color: 'orange', icon: 'fas fa-warehouse', trend: 0, sub: '加载中...' },
  { label: '待执行调度指令', value: '--', color: 'purple', icon: 'fas fa-tasks', trend: 0, sub: '加载中...' },
  { label: '平均作业时长', value: '--', color: 'red', icon: 'fas fa-clock', trend: 0, sub: '加载中...' },
])

function setYardRef(zoneId, el) {
  if (el) yardRefs[zoneId] = el
}

function buildTrendChart(hourlySea, hourlyLand) {
  if (!trendCanvas.value) return
  const labels = Array.from({ length: 24 }, (_, i) => `${String(i).padStart(2, '0')}:00`)
  if (chartInstance) chartInstance.destroy()
  chartInstance = new Chart(trendCanvas.value, {
    type: 'line',
    data: {
      labels,
      datasets: [
        {
          label: '海侧作业量', data: hourlySea,
          borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,0.1)', fill: true, tension: 0.4,
        },
        {
          label: '陆侧作业量', data: hourlyLand,
          borderColor: '#22c55e', backgroundColor: 'rgba(34,197,94,0.1)', fill: true, tension: 0.4,
        },
      ],
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: 'top' } },
      scales: { y: { beginAtZero: true } },
    },
  })
}

function renderYardMap(zoneId) {
  const container = yardRefs[zoneId]
  if (!container) return
  container.innerHTML = ''
  const slots = yardSlotMap[zoneId] || []
  if (!slots.length) {
    container.innerHTML = '<div style="text-align:center;padding:20px;color:#94a3b8;font-size:12px;">无箱位数据</div>'
    return
  }
  for (const slot of slots) {
    const el = document.createElement('div')
    el.className = `yard-slot ${slot.slot_status || 'empty'}`
    el.innerHTML = `<div class="slot-id">${slot.slot_id?.slice(-4) || '--'}</div>`
    if (slot.slot_status === 'occupied') el.innerHTML += '<div class="slot-status">箱</div>'
    el.onclick = () => {
      const texts = { empty: '空闲', occupied: '已占用', reserved: '预留', maintenance: '维护中' }
      appStore.showToast(`箱位 ${slot.slot_id} | 状态：${texts[slot.slot_status] || slot.slot_status}`, 'info')
    }
    container.appendChild(el)
  }
}

async function fetchDashboardData() {
  loading.value = true
  error.value = false

  try {
    const results = await Promise.allSettled([
      getInventoryList({ page_size: 1 }),
      getSeaInboundList({ page_size: 1 }),
      getLandInboundList({ page_size: 1 }),
      api.get('/yard-zones'),
      getDispatchOrderList({ execution_status: 'issued', page_size: 1 }),
      getOperationList({ page_size: 1000 }),
    ])

    const [
      inventoryR, seaInR, landInR, zonesR, pendingR, opsR,
    ] = results

    const totalContainers = inventoryR.status === 'fulfilled' ? (inventoryR.value?.total ?? 0) : -1
    const seaToday = seaInR.status === 'fulfilled' ? (seaInR.value?.total ?? 0) : -1
    const landToday = landInR.status === 'fulfilled' ? (landInR.value?.total ?? 0) : -1
    const zones = zonesR.status === 'fulfilled' ? (zonesR.data ?? []) : []
    const pendingCount = pendingR.status === 'fulfilled' ? (pendingR.value?.total ?? 0) : -1
    const ops = opsR.status === 'fulfilled' ? (opsR.value?.items ?? []) : []

    if (results.some(r => r.status === 'rejected')) error.value = true

    // 堆积利用率
    const totalSlots = zones.reduce((s, z) => s + z.total_slots, 0)
    const occupiedSlots = zones.reduce((s, z) => s + z.occupied_slots, 0)
    const utilPct = totalSlots ? Math.round((occupiedSlots / totalSlots) * 1000) / 10 : 0

    // 平均作业时长
    const opsWithDuration = ops.filter(o => o.duration_minutes)
    const avgMin = opsWithDuration.length
      ? Math.round(opsWithDuration.reduce((s, o) => s + o.duration_minutes, 0) / opsWithDuration.length)
      : 0

    statCards[0].value = totalContainers >= 0 ? totalContainers.toLocaleString() : '--'
    statCards[0].sub = '当前在场'
    statCards[1].value = seaToday >= 0 ? String(seaToday) : '--'
    statCards[1].sub = '海侧进出'
    statCards[2].value = landToday >= 0 ? String(landToday) : '--'
    statCards[2].sub = '陆侧进出'
    statCards[3].value = `${utilPct}%`
    statCards[3].sub = `${occupiedSlots}/${totalSlots} 箱位`
    statCards[4].value = pendingCount >= 0 ? String(pendingCount) : '--'
    statCards[4].sub = '待处理'
    statCards[5].value = avgMin ? `${avgMin}min` : '--'
    statCards[5].sub = opsWithDuration.length ? `${opsWithDuration.length} 条样本` : ''
  } catch {
    error.value = true
  } finally {
    loading.value = false
  }
}

async function fetchTrendData() {
  trendLoading.value = true
  const hourlySea = new Array(24).fill(0)
  const hourlyLand = new Array(24).fill(0)

  try {
    const { items } = await getOperationList({ page_size: 1000 })
    for (const op of items || []) {
      if (!op.created_at) continue
      const hour = new Date(op.created_at).getHours()
      if (op.source_operation === 'sea') hourlySea[hour]++
      else hourlyLand[hour]++
    }
    buildTrendChart(hourlySea, hourlyLand)
  } catch {
    buildTrendChart(hourlySea, hourlyLand) // fallback with zeros
  } finally {
    trendLoading.value = false
  }
}

async function fetchYardData() {
  yardLoading.value = true
  try {
    const [zonesRes, slotsRes] = await Promise.all([
      api.get('/yard-zones'),
      api.get('/yard-slots', { params: { page_size: 2000 } }),
    ])
    yardZones.value = zonesRes.data || []

    const allSlots = slotsRes.data?.items || []
    for (const z of yardZones.value) {
      yardSlotMap[z.zone_id] = allSlots.filter(s => s.zone_id === z.zone_id)
    }
    await nextTick()
    for (const z of yardZones.value) {
      renderYardMap(z.zone_id)
    }
  } catch {
    yardZones.value = []
  } finally {
    yardLoading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
  fetchTrendData()
  fetchYardData()
})
</script>
