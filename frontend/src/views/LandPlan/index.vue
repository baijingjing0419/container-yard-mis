<template>
  <div class="fade-in">
    <div class="page-title">陆侧作业计划</div>
    <div class="page-subtitle">闸口作业计划与集卡调度统筹管理</div>
    <div class="card">
      <div class="card-header">
        <div class="card-title">今日闸口作业计划</div>
        <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增计划</button>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>计划编号</th><th>计划类型</th><th>预计箱量</th><th>时间段</th><th>闸口通道</th><th>完成进度</th><th>状态</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-if="loading"><td colspan="8" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="8" style="text-align:center;color:#94a3b8;padding:30px;">暂无计划数据</td></tr>
            <tr v-for="item in list" :key="item.plan_id">
              <td><strong>{{ item.plan_id }}</strong></td>
              <td>{{ item.plan_type }}</td>
              <td>{{ item.actual_container_count || 0 }} / {{ item.planned_container_count || 0 }}箱</td>
              <td>{{ formatTimeRange(item.planned_start_time, item.planned_end_time) }}</td>
              <td>{{ item.assigned_gate_lanes || '--' }}</td>
              <td>
                <div style="width:100%;background:#e2e8f0;border-radius:4px;height:8px;">
                  <div :style="{ width: (item.completion_rate || 0) + '%' }" :class="item.completion_rate > 50 ? 'bg-green-500' : 'bg-blue-500'" style="height:100%;border-radius:4px;transition:width 0.3s;"></div>
                </div>
                <span style="font-size:11px;color:#64748b;">{{ item.completion_rate || 0 }}% ({{ item.actual_container_count || 0 }}/{{ item.planned_container_count || 0 }})</span>
              </td>
              <td><StatusBadge :status="planStatusClass(item.plan_status)" :text="planStatusText(item.plan_status)" /></td>
              <td><button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i></button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <BaseModal title="新增陆侧作业计划" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">计划编号 <span style="color:red">*</span></label><input v-model="form.plan_id" class="form-input" placeholder="如: LP-20260528-01"></div>
      <div class="form-group"><label class="form-label">计划类型 <span style="color:red">*</span></label><select v-model="form.plan_type" class="form-input"><option value="inbound_outbound">进出口</option><option value="inbound_delivery">进口提箱</option><option value="outbound_export">出口进箱</option></select></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">预计箱量</label><input v-model.number="form.planned_container_count" type="number" class="form-input"></div>
        <div class="form-group"><label class="form-label">闸口通道</label><input v-model="form.assigned_gate_lanes" class="form-input" placeholder="如: 1,2,3"></div>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getLandPlanList, createLandPlan } from '../../api/landPlan'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'

const list = ref([]); const loading = ref(true); const showModal = ref(false)
const form = reactive({ plan_id:'', plan_type:'inbound_outbound', planned_container_count:0, assigned_gate_lanes:'', plan_status:'draft' })
function planStatusClass(s) { return { draft:'pending', approved:'processing', executing:'processing', completed:'completed', cancelled:'warning' }[s] || 'pending' }
function planStatusText(s) { return { draft:'草稿', approved:'已批准', executing:'执行中', completed:'已完成', cancelled:'已取消' }[s] || s }
function formatTimeRange(start, end) { const s=start?start.substring(0,16):'--'; const e=end?end.substring(11,16):'--'; return `${s} - ${e}` }
async function fetchData() { loading.value=true; try { const d=await getLandPlanList({page_size:100}); list.value=d?.items||[] } finally { loading.value=false } }
function openCreate() { Object.assign(form,{plan_id:'',plan_type:'inbound_outbound',planned_container_count:0,assigned_gate_lanes:'',plan_status:'draft'}); showModal.value=true }
async function handleSave() { if(!form.plan_id)return alert('请输入计划编号'); try{await createLandPlan({...form});showModal.value=false;alert('新增成功');fetchData()}catch(_){} }
onMounted(fetchData)
</script>
