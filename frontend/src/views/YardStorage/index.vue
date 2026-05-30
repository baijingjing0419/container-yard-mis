<template>
  <div class="fade-in">
    <div class="page-title">集装箱堆存日常管理</div>
    <div class="page-subtitle">堆场空间规划、集装箱台账与库存预警</div>

    <div class="stats-grid" style="grid-template-columns: repeat(3, 1fr);">
      <div class="stat-card" v-for="zone in zones" :key="zone.zone_id">
        <div class="stat-header">
          <div>
            <div class="stat-value">{{ zone.zone_name }}: {{ zone.occupied_slots }}箱</div>
            <div class="stat-label">{{ zone.zone_type === 'import' ? '进口箱区' : zone.zone_type === 'export' ? '出口箱区' : '中转箱区' }} - 利用率 {{ zone.utilization_rate }}%</div>
          </div>
          <div class="stat-icon" :class="zone.utilization_rate > 90 ? 'red' : zone.utilization_rate > 70 ? 'orange' : 'green'">
            <i :class="zone.utilization_rate > 90 ? 'fas fa-exclamation-triangle' : zone.utilization_rate > 70 ? 'fas fa-chart-line' : 'fas fa-check'"></i>
          </div>
        </div>
        <div :class="['stat-change', zone.utilization_rate > 90 ? 'down' : 'up']">
          <i :class="zone.utilization_rate > 90 ? 'fas fa-exclamation-triangle' : 'fas fa-check'"></i>
          {{ zone.utilization_rate > 90 ? '接近饱和' : '状态正常' }}
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-title">场内集装箱台账</div>
        <div class="search-bar" style="margin-bottom:0;">
          <input v-model="searchQuery" class="search-input" placeholder="搜索箱号、船名、位置..." @keyup.enter="fetchData">
          <button class="btn btn-primary" @click="fetchData"><i class="fas fa-search"></i> 搜索</button>
          <button class="btn btn-primary" @click="openCreate"><i class="fas fa-plus"></i> 新增台账</button>
        </div>
      </div>
      <div class="card-body" style="padding:0;">
        <div v-bind="containerProps" class="virtual-scroll-container">
          <table class="data-table">
            <thead><tr><th>箱号</th><th>箱型</th><th>当前状态</th><th>当前堆位</th><th>历史位置</th><th>入场时间</th><th>预计出场</th><th>停留时长</th><th>船名航次</th><th>操作</th></tr></thead>
            <tbody>
              <tr v-if="loading"><td colspan="10" style="text-align:center;color:#94a3b8;padding:30px;">加载中...</td></tr>
              <tr v-else-if="!list.length"><td colspan="10" style="text-align:center;color:#94a3b8;padding:30px;">暂无数据</td></tr>
              <tr v-for="{ data: item } in virtualList" :key="item.inventory_id">
                <td><strong style="color:#1e40af;">{{ item.container_id }}</strong></td>
                <td>{{ item.container_type }}</td>
                <td><StatusBadge :status="item.is_overdue?'warning':'completed'" :text="item.is_overdue?'超期':'在堆'" /></td>
                <td>{{ item.slot_label || item.current_slot_id || '--' }}</td>
                <td>{{ item.previous_slot_id || '--' }}</td>
                <td>{{ item.entry_time ? item.entry_time.substring(0,16) : '--' }}</td>
                <td>{{ item.expected_exit_time ? item.expected_exit_time.substring(0,10) : '--' }}</td>
                <td>{{ item.dwell_time_hours ? item.dwell_time_hours+'小时' : '--' }}</td>
                <td>{{ item.ship_name || item.ship_id || '--' }}</td>
                <td><button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i></button><button class="btn btn-sm btn-secondary"><i class="fas fa-map-marker-alt"></i></button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <BaseModal title="新增场内台账" :visible="showModal" @close="showModal=false" @save="handleSave">
      <div class="form-group"><label class="form-label">箱号 <span style="color:red">*</span></label><input v-model="form.container_id" class="form-input" placeholder="请输入箱号"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group"><label class="form-label">箱型</label><select v-model="form.container_type" class="form-input"><option>20GP</option><option>40GP</option><option>40HQ</option></select></div>
        <div class="form-group"><label class="form-label">关联船名航次</label><input v-model="form.ship_id" class="form-input" placeholder="如: COSCO-2405"></div>
      </div>
      <div class="form-group"><label class="form-label">当前堆位</label><input v-model="form.current_slot_id" class="form-input" placeholder="如: A-12-04"></div>
      <div class="form-group"><label class="form-label">来源类型</label><select v-model="form.source_type" class="form-input"><option value="sea_inbound">海侧入场</option><option value="land_inbound">陆侧入场</option></select></div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useVirtualList } from '@vueuse/core'
import { getInventoryList, createInventory } from '../../api/yardInventory'
import api from '../../api/request'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'

const list = ref([]); const loading = ref(true); const showModal = ref(false); const searchQuery = ref('')
const zones = ref([])
const form = reactive({ container_id:'', container_type:'40HQ', ship_id:'', current_slot_id:'', source_type:'sea_inbound', container_status:'in_yard' })

const { list: virtualList, containerProps, wrapperProps } = useVirtualList(list, { itemHeight: 48, overscan: 10 })

async function fetchData() { loading.value=true; try { const p={page_size:500}; if(searchQuery.value)p.container_id=searchQuery.value; const d=await getInventoryList(p); list.value=d?.items||[] } finally { loading.value=false } }
async function fetchZones() { try { const r = await api.get('/yard-zones'); zones.value = r.data || [] } catch (_) {} }
function openCreate() { Object.assign(form,{container_id:'',container_type:'40HQ',ship_id:'',current_slot_id:'',source_type:'sea_inbound',container_status:'in_yard'}); showModal.value=true }
async function handleSave() { if(!form.container_id)return alert('请输入箱号'); try{await createInventory({...form});showModal.value=false;alert('新增成功');fetchData()}catch(_){} }
onMounted(() => { fetchData(); fetchZones() })
</script>
