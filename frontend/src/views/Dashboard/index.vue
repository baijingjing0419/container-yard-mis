<template>
  <div class="fade-in">
    <div class="page-title">运营总览 Dashboard</div>
    <div class="page-subtitle">实时监控码头堆场运营状态与关键指标</div>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">2,847</div>
            <div class="stat-label">场内集装箱总量</div>
          </div>
          <div class="stat-icon blue"><i class="fas fa-box"></i></div>
        </div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> 12.5% 较昨日</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">156</div>
            <div class="stat-label">今日海侧作业量</div>
          </div>
          <div class="stat-icon cyan"><i class="fas fa-ship"></i></div>
        </div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> 8.3% 较昨日</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">423</div>
            <div class="stat-label">今日陆侧作业量</div>
          </div>
          <div class="stat-icon green"><i class="fas fa-truck"></i></div>
        </div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> 15.2% 较昨日</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">87.3%</div>
            <div class="stat-label">堆场利用率</div>
          </div>
          <div class="stat-icon orange"><i class="fas fa-warehouse"></i></div>
        </div>
        <div class="stat-change down"><i class="fas fa-arrow-down"></i> 2.1% 较昨日</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">28</div>
            <div class="stat-label">待执行调度指令</div>
          </div>
          <div class="stat-icon purple"><i class="fas fa-tasks"></i></div>
        </div>
        <div class="stat-change down"><i class="fas fa-arrow-down"></i> 5 较上小时</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">32min</div>
            <div class="stat-label">平均作业时长</div>
          </div>
          <div class="stat-icon red"><i class="fas fa-clock"></i></div>
        </div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> 3min 较昨日</div>
      </div>
    </div>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
      <div class="card">
        <div class="card-header">
          <div class="card-title"><i class="fas fa-chart-area" style="margin-right: 8px; color: #3b82f6;"></i>24小时作业趋势</div>
          <div>
            <button class="btn btn-sm btn-secondary">今日</button>
            <button class="btn btn-sm btn-secondary">本周</button>
            <button class="btn btn-sm btn-secondary">本月</button>
          </div>
        </div>
        <div class="card-body">
          <div class="chart-container">
            <canvas ref="trendChart"></canvas>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-header">
          <div class="card-title"><i class="fas fa-bell" style="margin-right: 8px; color: #f97316;"></i>实时告警</div>
          <span class="status-badge warning"><span class="dot red"></span>5 条未处理</span>
        </div>
        <div class="card-body">
          <div class="timeline">
            <div class="timeline-item">
              <div class="timeline-dot" style="background: #ef4444; box-shadow: 0 0 0 2px #ef4444;"></div>
              <div class="timeline-time">11:18:32</div>
              <div class="timeline-title">堆场A区-12B 集装箱超期滞留</div>
              <div class="timeline-content">箱号 MSKU7892345 滞留时长超过72小时，需紧急处理</div>
            </div>
            <div class="timeline-item">
              <div class="timeline-dot" style="background: #f97316; box-shadow: 0 0 0 2px #f97316;"></div>
              <div class="timeline-time">11:15:07</div>
              <div class="timeline-title">海侧作业计划延误</div>
              <div class="timeline-content">航次 COSCO-2405 卸船作业延误30分钟</div>
            </div>
            <div class="timeline-item">
              <div class="timeline-dot" style="background: #3b82f6; box-shadow: 0 0 0 2px #3b82f6;"></div>
              <div class="timeline-time">11:02:45</div>
              <div class="timeline-title">闸口通行拥堵预警</div>
              <div class="timeline-content">陆侧闸口平均等待时间超过15分钟</div>
            </div>
            <div class="timeline-item">
              <div class="timeline-dot" style="background: #3b82f6; box-shadow: 0 0 0 2px #3b82f6;"></div>
              <div class="timeline-time">10:48:12</div>
              <div class="timeline-title">场桥设备维护提醒</div>
              <div class="timeline-content">YC-03号场桥达到保养周期，建议安排维护</div>
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
          <div style="display: flex; gap: 20px;">
            <div style="flex: 1;">
              <div style="font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #1e40af;">A区 - 进口箱区</div>
              <div class="yard-map" ref="yardA"></div>
            </div>
            <div style="flex: 1;">
              <div style="font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #1e40af;">B区 - 出口箱区</div>
              <div class="yard-map" ref="yardB"></div>
            </div>
            <div style="flex: 1;">
              <div style="font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #1e40af;">C区 - 中转箱区</div>
              <div class="yard-map" ref="yardC"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import Chart from 'chart.js/auto'

const trendChart = ref(null)
const yardA = ref(null)
const yardB = ref(null)
const yardC = ref(null)

function generateYardMap(container) {
  if (!container) return
  const statuses = ['occupied','occupied','occupied','empty','occupied','reserved','occupied','empty','occupied','maintenance','occupied','empty']
  container.innerHTML = ''
  for (let i = 1; i <= 48; i++) {
    const slot = document.createElement('div')
    const status = statuses[Math.floor(Math.random() * statuses.length)]
    slot.className = `yard-slot ${status}`
    slot.innerHTML = `<div class="slot-id">${String(i).padStart(2, '0')}</div>`
    if (status === 'occupied') slot.innerHTML += '<div class="slot-status">箱</div>'
    slot.onclick = () => alert(`箱位 ${status === 'occupied' ? '已占用' : status === 'empty' ? '空闲' : status === 'reserved' ? '预留' : '维护中'}`)
    container.appendChild(slot)
  }
}

onMounted(() => {
  // Init trend chart
  if (trendChart.value) {
    new Chart(trendChart.value, {
      type: 'line',
      data: {
        labels: ['00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00'],
        datasets: [{
          label: '海侧作业量', data: [12,8,25,45,38,42,35,20],
          borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,0.1)', fill: true, tension: 0.4,
        }, {
          label: '陆侧作业量', data: [5,3,15,35,55,48,30,15],
          borderColor: '#22c55e', backgroundColor: 'rgba(34,197,94,0.1)', fill: true, tension: 0.4,
        }]
      },
      options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'top' } }, scales: { y: { beginAtZero: true } } }
    })
  }
  // Generate yard maps
  generateYardMap(yardA.value)
  generateYardMap(yardB.value)
  generateYardMap(yardC.value)
})
</script>
