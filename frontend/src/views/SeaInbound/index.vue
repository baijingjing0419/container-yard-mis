<template>
  <div class="fade-in">
    <div class="page-title">海侧进箱作业</div>
    <div class="page-subtitle">管理海运进口集装箱卸船入场全流程</div>

    <div class="alert alert-info">
      <i class="fas fa-info-circle"></i>
      <span>当前作业：航次 <strong>COSCO-2405</strong> 正在卸船，预计剩余作业时间 2小时35分钟</span>
    </div>

    <div class="flow-diagram">
      <div class="flow-node active">船舶靠泊</div>
      <div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node active">岸桥卸船</div>
      <div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node active">内集卡转运</div>
      <div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">场桥落箱</div>
      <div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">信息录入</div>
      <div class="flow-arrow"><i class="fas fa-chevron-right"></i></div>
      <div class="flow-node">堆存确认</div>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-title">今日海侧进箱作业列表</div>
        <div style="display: flex; gap: 10px;">
          <button class="btn btn-primary" @click="openCreateDialog">
            <i class="fas fa-plus"></i> 新增进箱记录
          </button>
          <button class="btn btn-secondary"><i class="fas fa-filter"></i> 筛选</button>
          <button class="btn btn-secondary"><i class="fas fa-download"></i> 导出</button>
        </div>
      </div>
      <div class="card-body" style="padding: 0;">
        <table class="data-table">
          <thead>
            <tr>
              <th>箱号</th><th>箱型</th><th>船名航次</th><th>舱单信息</th>
              <th>入场时间</th><th>目标堆位</th><th>残损情况</th>
              <th>作业状态</th><th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading"><td colspan="9" style="text-align:center;padding:30px;color:#94a3b8;">加载中...</td></tr>
            <tr v-else-if="!list.length"><td colspan="9" style="text-align:center;padding:30px;color:#94a3b8;">暂无数据</td></tr>
            <tr v-for="item in list" :key="item.container_id">
              <td><strong style="color:#1e40af;">{{ item.container_id }}</strong></td>
              <td>{{ item.container_type }}</td>
              <td>{{ item.ship_name || item.ship_id }}</td>
              <td>{{ item.manifest_info || '--' }}</td>
              <td>{{ item.entry_time ? item.entry_time.substring(0,16) : '--' }}</td>
              <td>{{ item.target_slot_label || item.target_slot_id || '--' }}</td>
              <td>
                <StatusBadge :status="item.damage_status === '完好' ? 'completed' : 'warning'" :text="item.damage_status || '完好'" />
              </td>
              <td>
                <StatusBadge :status="statusClass(item.process_status)" :text="statusText(item.process_status)" />
              </td>
              <td>
                <button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i></button>
                <button class="btn btn-sm btn-secondary"><i class="fas fa-edit"></i></button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 新增弹窗 -->
    <BaseModal title="新增海侧进箱记录" :visible="showModal" @close="showModal = false" @save="handleSave">
      <div class="form-group">
        <label class="form-label">箱号 <span style="color:red">*</span></label>
        <input v-model="form.container_id" class="form-input" placeholder="请输入集装箱号">
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group">
          <label class="form-label">箱型</label>
          <select v-model="form.container_type" class="form-input">
            <option>20GP</option><option>40GP</option><option>40HQ</option><option>45HQ</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">船名航次 <span style="color:red">*</span></label>
          <input v-model="form.ship_id" class="form-input" placeholder="如: COSCO-2405">
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">航次号 <span style="color:red">*</span></label>
        <input v-model="form.voyage_no" class="form-input" placeholder="如: V2405">
      </div>
      <div class="form-group">
        <label class="form-label">舱单信息</label>
        <input v-model="form.manifest_info" class="form-input" placeholder="舱位编号">
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group">
          <label class="form-label">目标堆位</label>
          <input v-model="form.target_slot_id" class="form-input" placeholder="如: A-12-04">
        </div>
        <div class="form-group">
          <label class="form-label">残损情况</label>
          <select v-model="form.damage_status" class="form-input">
            <option>完好</option><option>轻微变形</option><option>严重损坏</option>
          </select>
        </div>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getSeaInboundList, createSeaInbound } from '../../api/seaInbound'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'

const list = ref([])
const loading = ref(true)
const showModal = ref(false)

const defaultForm = {
  container_id: '', container_type: '40HQ', ship_id: '', voyage_no: '',
  manifest_info: '', target_slot_id: '', damage_status: '完好', process_status: 'pending',
}
const form = reactive({ ...defaultForm })

function statusClass(s) {
  return { pending:'pending', transiting:'processing', landed:'completed', completed:'completed' }[s] || 'pending'
}
function statusDot(s) {
  return { pending:'orange', transiting:'blue', landed:'green', completed:'green' }[s] || 'orange'
}
function statusText(s) {
  return { pending:'待处理', transiting:'转运中', landed:'已落箱', completed:'已完成' }[s] || s
}

async function fetchData() {
  loading.value = true
  try {
    const data = await getSeaInboundList({ page_size: 100 })
    list.value = data?.items || []
  } finally {
    loading.value = false
  }
}

function openCreateDialog() {
  Object.assign(form, defaultForm)
  showModal.value = true
}

const appStore = useAppStore()

async function handleSave() {
  if (!form.container_id) return appStore.showToast('请输入箱号', 'error')
  if (!form.ship_id) return appStore.showToast('请输入船名航次', 'error')
  if (!form.voyage_no) return appStore.showToast('请输入航次号', 'error')
  try {
    await createSeaInbound({ ...form })
    showModal.value = false
    appStore.showToast('新增成功', 'success')
    fetchData()
  } catch (_) { /* error already handled by interceptor */ }
}

onMounted(fetchData)
</script>
