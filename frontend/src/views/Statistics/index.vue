<template>
  <div class="fade-in">
    <div class="page-title">作业效率统计分析</div>
    <div class="page-subtitle">基于实时作业数据的效率统计与绩效分析</div>

    <div v-if="loading" style="text-align:center;padding:60px;color:#94a3b8;">加载统计数据中...</div>

    <template v-else>
      <div class="stats-grid">
        <div class="stat-card" v-for="card in statCards" :key="card.label">
          <div class="stat-header">
            <div><div class="stat-value">{{ card.value }}</div><div class="stat-label">{{ card.label }}</div></div>
            <div class="stat-icon" :class="card.color"><i :class="card.icon"></i></div>
          </div>
          <div class="stat-change" :class="card.trend >= 0 ? 'up' : 'down'">
            <i :class="card.trend >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i> {{ card.sub }}
          </div>
        </div>
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div class="card">
          <div class="card-header"><div class="card-title">各班组作业效率对比</div></div>
          <div class="card-body"><div class="chart-container"><canvas ref="efficiencyChartRef"></canvas></div></div>
        </div>
        <div class="card">
          <div class="card-header"><div class="card-title">月度作业量趋势</div></div>
          <div class="card-body"><div class="chart-container"><canvas ref="monthlyChartRef"></canvas></div></div>
        </div>
      </div>

      <div class="card" style="margin-top: 20px;">
        <div class="card-header"><div class="card-title">设备利用率分析</div></div>
        <div class="card-body"><div class="chart-container"><canvas ref="equipmentChartRef"></canvas></div></div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue'
import Chart from 'chart.js/auto'
import { getOperationList } from '../../api/yardOperation'
import api from '../../api/request'

const loading = ref(true)
const efficiencyChartRef = ref(null)
const monthlyChartRef = ref(null)
const equipmentChartRef = ref(null)
let charts = []

const statCards = reactive([
  { label: '作业总次数', value: '--', color: 'green', icon: 'fas fa-tachometer-alt', trend: 0, sub: '加载中...' },
  { label: '平均作业时长', value: '--', color: 'blue', icon: 'fas fa-clock', trend: 0, sub: '加载中...' },
  { label: '完成率', value: '--', color: 'cyan', icon: 'fas fa-check-circle', trend: 0, sub: '加载中...' },
  { label: '闸口平均通行', value: '--', color: 'orange', icon: 'fas fa-stopwatch', trend: 0, sub: '加载中...' },
])

async function fetchData() {
  loading.value = true
  try {
    const [opsRes, gateRes] = await Promise.all([
      getOperationList({ page_size: 1000 }),
      api.get('/gate-records', { params: { page_size: 1000 } }),
    ])
    const items = opsRes?.items || []
    const gateItems = gateRes.data?.items || []

    const total = items.length
    const withDuration = items.filter(i => i.duration_minutes)
    const avgMin = withDuration.length
      ? Math.round(withDuration.reduce((s, i) => s + i.duration_minutes, 0) / withDuration.length)
      : 0
    const completed = items.filter(i => i.operation_status === 'completed').length
    const completionPct = total ? Math.round((completed / total) * 1000) / 10 : 0

    const gateWithDuration = gateItems.filter(i => i.pass_duration)
    const gateAvg = gateWithDuration.length
      ? Math.round(gateWithDuration.reduce((s, i) => s + i.pass_duration, 0) / gateWithDuration.length * 10) / 10
      : 0

    statCards[0].value = String(total)
    statCards[0].sub = `已完成 ${completed} 项`
    statCards[1].value = avgMin ? `${avgMin}min` : '--'
    statCards[1].sub = `${withDuration.length} 条样本`
    statCards[2].value = `${completionPct}%`
    statCards[2].sub = `${completed}/${total} 项`
    statCards[3].value = gateAvg ? `${gateAvg}min` : '--'
    statCards[3].sub = `${gateWithDuration.length} 条样本`

    return { items, gateItems }
  } catch {
    return { items: [], gateItems: [] }
  } finally {
    loading.value = false
  }
}

const SOURCE_LABELS = {
  sea_inbound: '海侧进箱', sea_outbound: '海侧出场',
  land_inbound: '陆侧进箱', land_outbound: '陆侧出场',
  dispatch: '中控调度', yard_shift: '场内调箱',
  岸桥班组: '岸桥班组', 场桥班组: '场桥班组', 闸口班组: '闸口班组', 内集卡班组: '内集卡班组',
}
function sourceLabel(k) { return SOURCE_LABELS[k] || k }

function buildCharts(items) {
  const deptMap = {}
  const equipMap = {}
  const monthMap = {}
  for (const op of items || []) {
    const dept = sourceLabel(op.execute_dept || op.source_operation || '其他')
    deptMap[dept] = (deptMap[dept] || 0) + 1
    const equip = op.equipment_id
    if (equip) equipMap[equip] = (equipMap[equip] || 0) + 1
    if (op.created_at) {
      const m = op.created_at.substring(0, 7)
      monthMap[m] = (monthMap[m] || 0) + 1
    }
  }

  if (efficiencyChartRef.value) {
    charts.push(new Chart(efficiencyChartRef.value, {
      type: 'bar', data: {
        labels: Object.keys(deptMap),
        datasets: [{ label: '作业次数', data: Object.values(deptMap), backgroundColor: ['#3b82f6','#06b6d4','#22c55e','#f97316','#8b5cf6','#ec4899'], borderRadius: 6 }]
      }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
    }))
  }

  const months = Object.keys(monthMap).sort()
  if (monthlyChartRef.value) {
    charts.push(new Chart(monthlyChartRef.value, {
      type: 'line', data: {
        labels: months.length ? months : ['暂无数据'],
        datasets: [{ label: '总作业量', data: months.length ? months.map(m => monthMap[m]) : [0], borderColor: '#1e40af', backgroundColor: 'rgba(30,64,175,0.1)', fill: true, tension: 0.4 }]
      }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
    }))
  }

  if (equipmentChartRef.value) {
    const equipLabels = Object.keys(equipMap)
    charts.push(new Chart(equipmentChartRef.value, {
      type: 'bar', data: {
        labels: equipLabels.length ? equipLabels : ['暂无数据'],
        datasets: [{ label: '作业次数', data: equipLabels.length ? equipLabels.map(e => equipMap[e]) : [0], backgroundColor: '#3b82f6', borderRadius: 6 }]
      }, options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true } } }
    }))
  }
}

onMounted(async () => {
  const { items } = await fetchData()
  buildCharts(items)
})

onBeforeUnmount(() => {
  charts.forEach(c => c.destroy())
  charts = []
})
</script>
