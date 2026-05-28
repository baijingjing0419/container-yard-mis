<template>
  <div class="fade-in">
    <div class="page-title">作业效率统计分析</div>
    <div class="page-subtitle">作业效率统计、人员与机械绩效核算</div>

    <div class="stats-grid">
      <div class="stat-card"><div class="stat-header"><div><div class="stat-value">92.5%</div><div class="stat-label">整体作业效率</div></div><div class="stat-icon green"><i class="fas fa-tachometer-alt"></i></div></div><div class="stat-change up"><i class="fas fa-arrow-up"></i> 2.3% 较上月</div></div>
      <div class="stat-card"><div class="stat-header"><div><div class="stat-value">28.5箱/小时</div><div class="stat-label">岸桥平均效率</div></div><div class="stat-icon blue"><i class="fas fa-ship"></i></div></div><div class="stat-change up"><i class="fas fa-arrow-up"></i> 1.2箱 较上月</div></div>
      <div class="stat-card"><div class="stat-header"><div><div class="stat-value">22.3箱/小时</div><div class="stat-label">场桥平均效率</div></div><div class="stat-icon cyan"><i class="fas fa-truck-loading"></i></div></div><div class="stat-change down"><i class="fas fa-arrow-down"></i> 0.5箱 较上月</div></div>
      <div class="stat-card"><div class="stat-header"><div><div class="stat-value">4.2分钟</div><div class="stat-label">闸口平均通行</div></div><div class="stat-icon orange"><i class="fas fa-stopwatch"></i></div></div><div class="stat-change up"><i class="fas fa-arrow-up"></i> 0.3min 较上月</div></div>
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
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import Chart from 'chart.js/auto'

const efficiencyChartRef = ref(null)
const monthlyChartRef = ref(null)
const equipmentChartRef = ref(null)
let charts = []

onMounted(() => {
  if (efficiencyChartRef.value) {
    charts.push(new Chart(efficiencyChartRef.value, {
      type: 'bar', data: {
        labels: ['岸桥一班','岸桥二班','场桥一班','场桥二班','闸口一班','闸口二班'],
        datasets: [{ label: '作业效率 (箱/小时)', data: [28.5,26.3,22.1,24.8,18.5,19.2], backgroundColor: ['#3b82f6','#3b82f6','#06b6d4','#06b6d4','#22c55e','#22c55e'], borderRadius: 6 }]
      }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
    }))
  }
  if (monthlyChartRef.value) {
    charts.push(new Chart(monthlyChartRef.value, {
      type: 'line', data: {
        labels: ['1月','2月','3月','4月','5月'],
        datasets: [{ label: '总作业量', data: [8500,9200,8800,9500,10200], borderColor: '#1e40af', backgroundColor: 'rgba(30,64,175,0.1)', fill: true, tension: 0.4 }]
      }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
    }))
  }
  if (equipmentChartRef.value) {
    charts.push(new Chart(equipmentChartRef.value, {
      type: 'bar', data: {
        labels: ['QC-01','QC-02','QC-03','YC-01','YC-02','YC-03','YC-04'],
        datasets: [
          { label: '利用率 (%)', data: [85,78,92,88,75,82,90], backgroundColor: '#3b82f6', borderRadius: 6 },
          { label: '故障率 (%)', data: [2,5,1,3,8,4,2], backgroundColor: '#ef4444', borderRadius: 6 }
        ]
      }, options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true, max: 100 } } }
    }))
  }
})

onBeforeUnmount(() => {
  charts.forEach(c => c.destroy())
  charts = []
})
</script>
