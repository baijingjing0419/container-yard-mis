<template>
  <div class="fade-in">
    <div class="page-title">陆侧进箱作业</div>
    <div class="page-subtitle">管理集卡通过闸口进入堆场全流程</div>
    <div class="alert alert-info"><i class="fas fa-info-circle"></i><span>当前闸口状态：<strong>{{ gateStats.openLanes }}</strong> 条通道开放，平均通行时间 <strong>{{ gateStats.avgTime }}分钟</strong></span></div>
    <div class="flow-diagram">
      <div class="flow-node">送箱/提箱申请</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node active">闸口单证核验</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node active">残损确认</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">闸口放行</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">场桥落箱</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">信息录入</div>
    </div>
    <div class="card">
      <div class="card-header">
        <div class="card-title">今日陆侧进箱作业列表</div>
        <div style="display:flex;gap:10px;">
          <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增进箱记录</button>

        </div>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>箱号</th><th>箱型</th><th>车牌号码</th><th>司机信息</th><th>单证信息</th><th>入场时间</th><th>目标堆位</th><th>残损确认</th><th>状态</th></tr></thead>
          <tbody>
            <tr v-if="loading"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">暂无数据</td></tr>
            <tr v-for="item in list" :key="item.container_id">
              <td><strong style="color:#1e40af;">{{ item.container_id }}</strong></td>
              <td>{{ item.container_type }}</td>
              <td>{{ item.truck_plate || '--' }}</td>
              <td>{{ item.driver_name || '--' }}</td>
              <td>{{ item.document_no || '--' }}</td>
              <td>{{ item.entry_time ? item.entry_time.substring(0,16) : '--' }}</td>
              <td>{{ item.target_slot_label || item.target_slot_id || '--' }}</td>
              <td><StatusBadge :status="item.damage_check === '完好' ? 'completed' : 'warning'" :text="item.damage_check || '完好'" /></td>
              <td><StatusBadge :status="statusClass(item.process_status)" :text="statusText(item.process_status)" /></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <BaseModal title="新增陆侧进箱记录" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">箱号 <span style="color:red">*</span></label><input v-model="form.container_id" class="form-input" placeholder="请输入集装箱号"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">箱型</label><select v-model="form.container_type" class="form-input"><option>20GP</option><option>40GP</option><option>40HQ</option><option>45HQ</option></select></div>
        <div class="form-group"><label class="form-label">车牌号码</label><input v-model="form.truck_plate" class="form-input" placeholder="如: 沪A·B8821"></div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">司机姓名</label><input v-model="form.driver_name" class="form-input" placeholder="司机姓名"></div>
        <div class="form-group"><label class="form-label">单证号</label><input v-model="form.document_no" class="form-input" placeholder="单证号"></div>
      </div>
      <div class="form-group"><label class="form-label">关联船名航次</label><input v-model="form.ship_id" class="form-input" placeholder="如: COSCO-2405"></div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getLandInboundList, createLandInbound } from '../../api/landInbound'
import api from '../../api/request'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'
import { useAppStore } from '../../store/app'

const list = ref([]); const loading = ref(true); const showModal = ref(false)
const gateStats = reactive({ openLanes: '--', avgTime: '--' })
const form = reactive({ container_id:'', container_type:'40HQ', truck_plate:'', driver_name:'', document_no:'', ship_id:'', process_status:'pending' })
function statusClass(s) { return { pending:'pending', gate_checking:'processing', landed:'completed', completed:'completed' }[s] || 'pending' }
function statusText(s) { return { pending:'待处理', gate_checking:'核验中', landed:'已落箱', completed:'已完成' }[s] || s }
async function fetchData() { loading.value=true; try { const d=await getLandInboundList({page_size:100}); list.value=d?.items||[] } finally { loading.value=false } }
function openCreate() { Object.assign(form,{container_id:'',container_type:'40HQ',truck_plate:'',driver_name:'',document_no:'',ship_id:'',process_status:'pending'}); showModal.value=true }
const appStore = useAppStore()

async function handleSave() { if(!form.container_id)return appStore.showToast('请输入箱号', 'error'); try{await createLandInbound({...form});showModal.value=false;appStore.showToast('新增成功', 'success');fetchData()}catch(_){} }
async function fetchGateStats() { try { const { data } = await api.get('/gate-records', { params: { io_type: 'inbound', page_size: 100 } }); const items = data?.items||[]; gateStats.openLanes = '3'; const withDur = items.filter(i=>i.pass_duration); gateStats.avgTime = withDur.length ? (withDur.reduce((s,i)=>s+i.pass_duration,0)/withDur.length).toFixed(1) : '--' } catch { gateStats.openLanes='--'; gateStats.avgTime='--' } }
onMounted(() => { fetchData(); fetchGateStats() })
</script>
