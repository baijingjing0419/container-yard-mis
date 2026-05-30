<template>
  <div class="fade-in">
    <div class="page-title">海侧作业计划</div>
    <div class="page-subtitle">船舶靠泊计划与装卸作业统筹管理</div>
    <div class="card">
      <div class="card-header">
        <div class="card-title">船舶靠泊计划</div>
        <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增计划</button>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>航次号</th><th>船舶名称</th><th>靠泊时间</th><th>离泊时间</th><th>入场箱量</th><th>出场箱量</th><th>作业进度</th><th>状态</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-if="loading"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">暂无计划数据</td></tr>
            <tr v-for="item in list" :key="item.plan_id">
              <td><strong>{{ item.voyage_no }}</strong></td>
              <td>{{ item.ship_name || item.ship_id }}</td>
              <td>{{ item.planned_berth_time ? item.planned_berth_time.substring(0,16) : '--' }}</td>
              <td>{{ item.planned_depart_time ? item.planned_depart_time.substring(0,16) : '--' }}</td>
              <td>{{ item.actual_inbound || 0 }} / {{ item.planned_inbound || 0 }}</td>
              <td>{{ item.actual_outbound || 0 }} / {{ item.planned_outbound || 0 }}</td>
              <td>
                <div style="width:100%;background:#e2e8f0;border-radius:4px;height:8px;">
                  <div :style="{ width: (item.completion_rate || 0) + '%' }" :class="item.completion_rate > 50 ? 'bg-green-500' : 'bg-blue-500'" style="height:100%;border-radius:4px;transition:width 0.3s;"></div>
                </div>
                <span style="font-size:11px;color:#64748b;">{{ item.completion_rate || 0 }}%</span>
              </td>
              <td><StatusBadge :status="planStatusClass(item.plan_status)" :text="planStatusText(item.plan_status)" /></td>
              <td><button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i></button><button class="btn btn-sm btn-secondary"><i class="fas fa-edit"></i></button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <BaseModal title="新增海侧作业计划" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">计划编号 <span style="color:red">*</span></label><input v-model="form.plan_id" class="form-input" placeholder="如: SP-20260528-01"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">计划类型</label><select v-model="form.plan_type" class="form-input"><option value="discharge">卸船</option><option value="load">装船</option></select></div>
        <div class="form-group"><label class="form-label">航次号 <span style="color:red">*</span></label><input v-model="form.voyage_no" class="form-input" placeholder="航次号"></div>
      </div>
      <div class="form-group"><label class="form-label">船舶编号 <span style="color:red">*</span></label><input v-model="form.ship_id" class="form-input" placeholder="如: COSCO-2405"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">计划入场箱量</label><input v-model.number="form.planned_inbound" type="number" class="form-input"></div>
        <div class="form-group"><label class="form-label">计划出场箱量</label><input v-model.number="form.planned_outbound" type="number" class="form-input"></div>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getSeaPlanList, createSeaPlan } from '../../api/seaPlan'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'

const list = ref([]); const loading = ref(true); const showModal = ref(false)
const form = reactive({ plan_id:'', plan_type:'discharge', voyage_no:'', ship_id:'', planned_inbound:0, planned_outbound:0, plan_status:'draft' })
function planStatusClass(s) { return { draft:'pending', approved:'processing', executing:'processing', completed:'completed', cancelled:'warning' }[s] || 'pending' }
function planStatusText(s) { return { draft:'草稿', approved:'已批准', executing:'执行中', completed:'已完成', cancelled:'已取消' }[s] || s }
async function fetchData() { loading.value=true; try { const d=await getSeaPlanList({page_size:100}); list.value=d?.items||[] } finally { loading.value=false } }
function openCreate() { Object.assign(form,{plan_id:'',plan_type:'discharge',voyage_no:'',ship_id:'',planned_inbound:0,planned_outbound:0,plan_status:'draft'}); showModal.value=true }
const appStore = useAppStore()

async function handleSave() { if(!form.plan_id)return appStore.showToast('请输入计划编号', 'error'); if(!form.voyage_no)return appStore.showToast('请输入航次号', 'error'); if(!form.ship_id)return appStore.showToast('请输入船舶编号', 'error'); try{await createSeaPlan({...form});showModal.value=false;appStore.showToast('新增成功', 'success');fetchData()}catch(_){} }
onMounted(fetchData)
</script>
