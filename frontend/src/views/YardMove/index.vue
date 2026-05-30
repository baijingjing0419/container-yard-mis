<template>
  <div class="fade-in">
    <div class="page-title">场内调箱作业</div>
    <div class="page-subtitle">管理集装箱在堆场内的调箱、翻箱、归位等作业</div>
    <div class="alert alert-info"><i class="fas fa-info-circle"></i><span>今日已执行调箱作业 <strong>{{ list.length }}</strong> 次</span></div>
    <div class="card">
      <div class="card-header">
        <div class="card-title">调箱作业记录</div>
        <div style="display:flex;gap:10px;">
          <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增调箱指令</button>
          <button class="btn btn-secondary"><i class="fas fa-filter"></i> 筛选</button>
        </div>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>作业记录号</th><th>作业类型</th><th>箱号</th><th>原堆位</th><th>目标堆位</th><th>作业机械</th><th>作业人员</th><th>开始时间</th><th>结束时间</th><th>作业状态</th></tr></thead>
          <tbody>
            <tr v-if="loading"><td colspan="10" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="10" style="text-align:center;color:#94a3b8;padding:30px;">暂无数据</td></tr>
            <tr v-for="item in list" :key="item.record_id">
              <td><strong>{{ item.record_id }}</strong></td>
              <td>{{ opTypeText(item.operation_type) }}</td>
              <td>{{ item.container_id }}</td>
              <td>{{ item.original_slot_label || item.original_slot_id || '--' }}</td>
              <td>{{ item.target_slot_label || item.target_slot_id || '--' }}</td>
              <td>{{ item.equipment_id || '--' }}</td>
              <td>{{ item.operator_name || '--' }}</td>
              <td>{{ item.start_time ? item.start_time.substring(0,16) : '--' }}</td>
              <td>{{ item.end_time ? item.end_time.substring(0,16) : '--' }}</td>
              <td><StatusBadge :status="opStatusClass(item.operation_status)" :text="opStatusText(item.operation_status)" /></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <BaseModal title="新增调箱指令" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">作业记录号 <span style="color:red">*</span></label><input v-model="form.record_id" class="form-input" placeholder="如: YM-20260528-089"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">作业类型</label><select v-model="form.operation_type" class="form-input"><option value="shift">翻箱</option><option value="land">落箱</option><option value="pick">提箱</option><option value="flip">倒箱</option></select></div>
        <div class="form-group"><label class="form-label">箱号 <span style="color:red">*</span></label><input v-model="form.container_id" class="form-input" placeholder="请输入箱号"></div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">箱型</label><select v-model="form.container_type" class="form-input"><option value="">-- 请选择 --</option><option value="20GP">20GP</option><option value="40GP">40GP</option><option value="40HQ">40HQ</option><option value="45HQ">45HQ</option></select></div>
        <div class="form-group"><label class="form-label">原堆位</label><input v-model="form.original_slot_id" class="form-input" placeholder="原堆位"></div>
      </div>
      <div class="form-group"><label class="form-label">作业机械编号</label><input v-model="form.equipment_id" class="form-input" placeholder="如: YC-02"></div>
      <div class="form-group"><label class="form-label">作业人员</label><input v-model="form.operator_name" class="form-input" placeholder="作业人员姓名"></div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getOperationList, createOperation } from '../../api/yardOperation'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'
import { useAppStore } from '../../store/app'

const list = ref([]); const loading = ref(true); const showModal = ref(false)
const form = reactive({ record_id:'', operation_type:'shift', container_id:'', container_type:'', original_slot_id:'', target_slot_id:'', equipment_id:'', operator_name:'', operation_status:'pending' })
function opTypeText(t) { return { shift:'翻箱', land:'落箱', pick:'提箱', flip:'倒箱', inspect:'查验' }[t] || t }
function opStatusClass(s) { return { pending:'pending', in_progress:'processing', completed:'completed', cancelled:'warning' }[s] || 'pending' }
function opStatusText(s) { return { pending:'待执行', in_progress:'进行中', completed:'已完成', cancelled:'已取消' }[s] || s }
async function fetchData() { loading.value=true; try { const d=await getOperationList({page_size:100}); list.value=d?.items||[] } finally { loading.value=false } }
function openCreate() { const now=new Date(); form.record_id='YM-'+now.getFullYear()+String(now.getMonth()+1).padStart(2,'0')+String(now.getDate()).padStart(2,'0')+'-'+String(now.getSeconds()).padStart(2,'0')+String(now.getMilliseconds()).padStart(3,'0'); form.operation_type='shift'; form.container_id=''; form.container_type=''; form.original_slot_id=''; form.target_slot_id=''; form.equipment_id=''; form.operator_name=''; showModal.value=true }
const appStore = useAppStore()

async function handleSave() { if(!form.container_id)return appStore.showToast('请输入箱号', 'error'); try{await createOperation({...form});showModal.value=false;appStore.showToast('新增成功', 'success');fetchData()}catch(_){} }
onMounted(fetchData)
</script>
