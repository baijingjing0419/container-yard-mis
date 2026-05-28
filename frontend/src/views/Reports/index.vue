<template>
  <div class="fade-in">
    <div class="page-title">报表中心</div>
    <div class="page-subtitle">箱量统计报表与作业效率分析报告</div>

    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 25px;">
      <div class="card report-card">
        <div class="card-body" style="text-align: center; padding: 30px;">
          <div style="width:60px;height:60px;background:rgba(59,130,246,0.1);border-radius:16px;display:flex;align-items:center;justify-content:center;margin:0 auto 15px;">
            <i class="fas fa-file-invoice" style="font-size:24px;color:#3b82f6;"></i>
          </div>
          <div style="font-size:16px;font-weight:600;color:#1e293b;margin-bottom:8px;">箱量统计报表</div>
          <div style="font-size:13px;color:#64748b;">按日/周/月统计场内集装箱数量变化</div>
          <button class="btn btn-primary" style="margin-top:15px;"><i class="fas fa-download"></i> 生成报表</button>
        </div>
      </div>
      <div class="card report-card">
        <div class="card-body" style="text-align: center; padding: 30px;">
          <div style="width:60px;height:60px;background:rgba(34,197,94,0.1);border-radius:16px;display:flex;align-items:center;justify-content:center;margin:0 auto 15px;">
            <i class="fas fa-chart-pie" style="font-size:24px;color:#22c55e;"></i>
          </div>
          <div style="font-size:16px;font-weight:600;color:#1e293b;margin-bottom:8px;">作业效率分析报告</div>
          <div style="font-size:13px;color:#64748b;">各作业环节效率分析与改进建议</div>
          <button class="btn btn-success" style="margin-top:15px;"><i class="fas fa-download"></i> 生成报告</button>
        </div>
      </div>
      <div class="card report-card">
        <div class="card-body" style="text-align: center; padding: 30px;">
          <div style="width:60px;height:60px;background:rgba(249,115,22,0.1);border-radius:16px;display:flex;align-items:center;justify-content:center;margin:0 auto 15px;">
            <i class="fas fa-clipboard-check" style="font-size:24px;color:#f97316;"></i>
          </div>
          <div style="font-size:16px;font-weight:600;color:#1e293b;margin-bottom:8px;">堆存周期分析</div>
          <div style="font-size:13px;color:#64748b;">集装箱堆存时长分布与超期预警</div>
          <button class="btn btn-secondary" style="margin-top:15px;"><i class="fas fa-download"></i> 生成报表</button>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header"><div class="card-title">历史报表记录</div></div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>报表编号</th><th>报表名称</th><th>报表类型</th><th>统计周期</th><th>生成时间</th><th>生成人员</th><th>状态</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-for="item in reportHistory" :key="item.id">
              <td><strong>{{ item.id }}</strong></td>
              <td>{{ item.name }}</td>
              <td>{{ item.type }}</td>
              <td>{{ item.period }}</td>
              <td>{{ item.time }}</td>
              <td>{{ item.author }}</td>
              <td><StatusBadge status="completed" :text="item.status" /></td>
              <td>
                <button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i></button>
                <button class="btn btn-sm btn-secondary"><i class="fas fa-download"></i></button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import StatusBadge from '../../components/StatusBadge.vue'

const reportHistory = ref([
  { id:'RPT-20260528-001', name:'2026年5月28日箱量统计日报', type:'箱量统计', period:'2026-05-28', time:'2026-05-28 11:00', author:'码头管理员', status:'已生成' },
  { id:'RPT-20260527-002', name:'2026年5月第4周作业效率周报', type:'效率分析', period:'2026-05-20 至 2026-05-27', time:'2026-05-27 18:00', author:'码头管理员', status:'已生成' },
])
</script>

<style scoped>
.report-card { cursor: pointer; transition: all 0.3s; }
.report-card:hover { transform: translateY(-3px); }
</style>
