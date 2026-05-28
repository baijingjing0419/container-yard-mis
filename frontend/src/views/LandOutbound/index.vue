<template>
  <div class="fade-in">
    <div class="page-title">陆侧出场作业</div>
    <div class="page-subtitle">管理提箱/出口集装箱通过闸口离开堆场全流程</div>
    <div class="card">
      <div class="card-header">
        <div class="card-title">今日陆侧出场作业列表</div>
        <div style="display:flex;gap:10px;">
          <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增出场记录</button>
          <button class="btn btn-secondary"><i class="fas fa-filter"></i> 筛选</button>
        </div>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>箱号</th><th>箱型</th><th>车牌号码</th><th>司机信息</th><th>提箱单证</th><th>原堆位</th><th>出场时间</th><th>放行状态</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-if="loading"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">暂无数据</td></tr>
            <tr v-for="item in list" :key="item.container_id">
              <td><strong style="color:#1e40af;">{{ item.container_id }}</strong></td>
              <td>{{ item.container_type }}</td>
              <td>{{ item.truck_plate || '--' }}</td>
              <td>{{ item.driver_name || '--' }}</td>
              <td>{{ item.pickup_document_no || '--' }}</td>
              <td>{{ item.slot_label || item.original_slot_id || '--' }}</td>
              <td>{{ item.exit_time ? item.exit_time.substring(0,16) : '--' }}</td>
              <td><StatusBadge :status="item.process_status==='released'?'completed':'pending'" :text="item.process_status==='released'?'已放行':item.process_status||'--'" /></td>
              <td><button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i></button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <BaseModal title="新增陆侧出场记录" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">箱号 <span style="color:red">*</span></label><input v-model="form.container_id" class="form-input" placeholder="请输入集装箱号"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">箱型</label><select v-model="form.container_type" class="form-input"><option>20GP</option><option>40GP</option><option>40HQ</option></select></div>
        <div class="form-group"><label class="form-label">车牌号码</label><input v-model="form.truck_plate" class="form-input" placeholder="如: 浙A·D7723"></div>
      </div>
      <div class="form-group"><label class="form-label">提箱单证号</label><input v-model="form.pickup_document_no" class="form-input" placeholder="提货单号"></div>
      <div class="form-group"><label class="form-label">关联船名航次</label><input v-model="form.ship_id" class="form-input" placeholder="如: COSCO-2405"></div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getLandOutboundList, createLandOutbound } from '../../api/landOutbound'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'

const list = ref([]); const loading = ref(true); const showModal = ref(false)
const form = reactive({ container_id:'', container_type:'40GP', truck_plate:'', pickup_document_no:'', ship_id:'', process_status:'planned' })
async function fetchData() { loading.value=true; try { const d=await getLandOutboundList({page_size:100}); list.value=d?.items||[] } finally { loading.value=false } }
function openCreate() { Object.assign(form,{container_id:'',container_type:'40GP',truck_plate:'',pickup_document_no:'',ship_id:'',process_status:'planned'}); showModal.value=true }
async function handleSave() { if(!form.container_id)return alert('请输入箱号'); try{await createLandOutbound({...form});showModal.value=false;alert('新增成功');fetchData()}catch(_){} }
onMounted(fetchData)
</script>
