<template>
  <div class="fade-in">
    <div class="page-title">海侧出场作业</div>
    <div class="page-subtitle">管理海运出口集装箱装船出场全流程</div>

    <div class="alert alert-success" v-if="activePlan">
      <i class="fas fa-check-circle"></i>
      <span>当前作业：航次 <strong>{{ activePlan.voyage_no }}</strong> ({{ activePlan.ship_id }}) 正在装船</span>
    </div>
    <div class="alert alert-success" v-else>
      <i class="fas fa-check-circle"></i>
      <span>当前无进行中的海侧出场计划</span>
    </div>

    <div class="flow-diagram">
      <div class="flow-node">装船计划</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node active">场桥提箱</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node active">内集卡转运</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">岸桥装船</div><div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">信息确认</div>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-title">今日海侧出场作业列表</div>
        <div style="display:flex;gap:10px;">
          <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增出场记录</button>
          <button class="btn btn-secondary"><i class="fas fa-filter"></i> 筛选</button>
        </div>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead><tr><th>箱号</th><th>箱型</th><th>船名航次</th><th>配载舱位</th><th>原堆位</th><th>出场时间</th><th>装船时间</th><th>单证信息</th><th>作业状态</th></tr></thead>
          <tbody>
            <tr v-if="loading"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">暂无数据</td></tr>
            <tr v-for="item in list" :key="item.container_id">
              <td><strong style="color:#1e40af;">{{ item.container_id }}</strong></td>
              <td>{{ item.container_type }}</td>
              <td>{{ item.ship_name || item.ship_id }}</td>
              <td>{{ item.stowage_position || '--' }}</td>
              <td>{{ item.slot_label || item.original_slot_id || '--' }}</td>
              <td>{{ item.exit_time ? item.exit_time.substring(0,16) : '--' }}</td>
              <td>{{ item.load_complete_time ? item.load_complete_time.substring(0,16) : '--' }}</td>
              <td>{{ item.document_info || item.customs_status || '--' }}</td>
              <td><StatusBadge :status="statusClass(item.process_status)" :text="statusText(item.process_status)" /></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <BaseModal title="新增海侧出场记录" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">箱号 <span style="color:red">*</span></label><input v-model="form.container_id" class="form-input" placeholder="请输入集装箱号"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">箱型</label><select v-model="form.container_type" class="form-input"><option>20GP</option><option>40GP</option><option>40HQ</option><option>45HQ</option></select></div>
        <div class="form-group"><label class="form-label">目标船名航次 <span style="color:red">*</span></label><input v-model="form.ship_id" class="form-input" placeholder="如: MAERSK-8821"></div>
      </div>
      <div class="form-group"><label class="form-label">航次号 <span style="color:red">*</span></label><input v-model="form.voyage_no" class="form-input" placeholder="如: V8821"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">配载舱位</label><input v-model="form.stowage_position" class="form-input" placeholder="舱位编号"></div>
        <div class="form-group"><label class="form-label">原堆位</label><input v-model="form.original_slot_id" class="form-input" placeholder="堆场位置"></div>
      </div>
      <div class="form-group"><label class="form-label">海关状态</label><select v-model="form.customs_status" class="form-input"><option value="cleared">已放行</option><option value="pending">待查验</option></select></div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getSeaOutboundList, createSeaOutbound } from '../../api/seaOutbound'
import api from '../../api/request'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'
import { useAppStore } from '../../store/app'

const list = ref([]); const loading = ref(true); const showModal = ref(false)
const activePlan = ref(null)
const form = reactive({ container_id:'', container_type:'40HQ', ship_id:'', voyage_no:'', stowage_position:'', original_slot_id:'', customs_status:'cleared', process_status:'planned' })
function statusClass(s) { return { planned:'pending', picking:'processing', transiting:'processing', loaded:'completed', completed:'completed' }[s] || 'pending' }
function statusText(s) { return { planned:'已计划', picking:'提箱中', transiting:'转运中', loaded:'已装船', completed:'已完成' }[s] || s }
async function fetchData() { loading.value=true; try { const d=await getSeaOutboundList({page_size:100}); list.value=d?.items||[] } finally { loading.value=false } }
function openCreate() { Object.assign(form,{container_id:'',container_type:'40HQ',ship_id:'',voyage_no:'',stowage_position:'',original_slot_id:'',customs_status:'cleared',process_status:'planned'}); showModal.value=true }
const appStore = useAppStore()

async function handleSave() { if(!form.container_id)return appStore.showToast('请输入箱号', 'error'); if(!form.ship_id)return appStore.showToast('请输入船名航次', 'error'); if(!form.voyage_no)return appStore.showToast('请输入航次号', 'error'); try{await createSeaOutbound({...form});showModal.value=false;appStore.showToast('新增成功', 'success');fetchData()}catch(_){} }
async function fetchActivePlan() { try { const { data } = await api.get('/sea-plans', { params: { plan_type: 'loading', plan_status: 'in_progress', page_size: 1 } }); activePlan.value = data?.items?.[0] || null } catch { activePlan.value = null } }
onMounted(() => { fetchData(); fetchActivePlan() })
</script>
