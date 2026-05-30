<template>
  <div class="fade-in">
    <div class="page-title">中控调度指令</div>
    <div class="page-subtitle">统筹堆场全流程作业的调度指令管理</div>

    <div class="stats-grid" style="grid-template-columns: repeat(4, 1fr);">
      <div class="stat-card">
        <div class="stat-header"><div><div class="stat-value">{{ stats.pending }}</div><div class="stat-label">待执行指令</div></div><div class="stat-icon orange"><i class="fas fa-clock"></i></div></div>
      </div>
      <div class="stat-card">
        <div class="stat-header"><div><div class="stat-value">{{ stats.total }}</div><div class="stat-label">今日已下发</div></div><div class="stat-icon blue"><i class="fas fa-paper-plane"></i></div></div>
      </div>
      <div class="stat-card">
        <div class="stat-header"><div><div class="stat-value">{{ stats.completed }}</div><div class="stat-label">今日已完成</div></div><div class="stat-icon green"><i class="fas fa-check-circle"></i></div></div>
      </div>
      <div class="stat-card">
        <div class="stat-header"><div><div class="stat-value">0</div><div class="stat-label">今日异常</div></div><div class="stat-icon red"><i class="fas fa-exclamation-triangle"></i></div></div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-title">调度指令列表</div>
        <div style="display: flex; gap: 10px;">
          <button class="btn btn-primary" @click="openCreateDialog">
            <i class="fas fa-plus"></i> 新增调度指令
          </button>
          <button class="btn btn-secondary"><i class="fas fa-filter"></i> 筛选</button>
        </div>
      </div>
      <div class="card-body" style="padding: 0;">
        <div v-bind="containerProps" class="virtual-scroll-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>指令号</th><th>指令类型</th><th>下达时间</th><th>执行部门</th>
                <th>箱号</th><th>原位置</th><th>目标位置</th><th>计划完成</th>
                <th>执行状态</th><th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading"><td colspan="10" style="text-align:center;padding:30px;color:#94a3b8;">加载中...</td></tr>
              <tr v-else-if="!list.length"><td colspan="10" style="text-align:center;padding:30px;color:#94a3b8;">暂无数据</td></tr>
              <tr v-for="{ data: item } in virtualList" :key="item.order_id">
                <td><strong>{{ item.order_id }}</strong></td>
                <td>{{ orderTypeText(item.order_type) }}</td>
                <td>{{ item.issue_time ? item.issue_time.substring(0,16) : '--' }}</td>
                <td>{{ item.execute_dept || '--' }}</td>
                <td>{{ item.container_id || '--' }}</td>
                <td>{{ item.original_position || '--' }}</td>
                <td>{{ item.target_position || '--' }}</td>
                <td>{{ item.planned_finish_time ? item.planned_finish_time.substring(0,16) : '--' }}</td>
                <td>
                  <StatusBadge :status="execStatusClass(item.execution_status)" :text="execStatusText(item.execution_status)" />
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
    </div>

    <!-- 新增弹窗 -->
    <BaseModal title="新增调度指令" :visible="showModal" @close="showModal = false" @save="handleSave">
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group">
          <label class="form-label">指令类型 <span style="color:red">*</span></label>
          <select v-model="form.order_type" class="form-input">
            <option value="sea_inbound">海侧进箱</option>
            <option value="sea_outbound">海侧出场</option>
            <option value="land_inbound">陆侧进箱</option>
            <option value="land_outbound">陆侧出场</option>
            <option value="yard_shift">场内调箱</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">执行部门 <span style="color:red">*</span></label>
          <select v-model="form.execute_dept" class="form-input">
            <option>岸桥班组</option><option>场桥班组</option>
            <option>闸口班组</option><option>内集卡班组</option>
          </select>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">箱号</label>
        <input v-model="form.container_id" class="form-input" placeholder="请输入集装箱号">
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:15px;">
        <div class="form-group">
          <label class="form-label">原位置</label>
          <input v-model="form.original_position" class="form-input" placeholder="原堆位或舱位">
        </div>
        <div class="form-group">
          <label class="form-label">目标位置 <span style="color:red">*</span></label>
          <input v-model="form.target_position" class="form-input" placeholder="目标堆位或出口">
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">优先级</label>
        <select v-model="form.priority_level" class="form-input">
          <option value="normal">普通</option><option value="high">高</option><option value="urgent">紧急</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">作业要求</label>
        <textarea v-model="form.operation_requirement" class="form-input" rows="3" placeholder="请输入具体作业要求..."></textarea>
      </div>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useVirtualList } from '@vueuse/core'
import { getDispatchOrderList, createDispatchOrder } from '../../api/dispatchOrder'
import BaseModal from '../../components/BaseModal.vue'
import StatusBadge from '../../components/StatusBadge.vue'
import { useAppStore } from '../../store/app'

const appStore = useAppStore()
const list = ref([])
const loading = ref(true)
const showModal = ref(false)
const stats = reactive({ total: 0, pending: 0, completed: 0 })

const { list: virtualList, containerProps, wrapperProps } = useVirtualList(list, { itemHeight: 48, overscan: 10 })

const defaultForm = {
  order_type: 'sea_inbound', execute_dept: '岸桥班组', container_id: '',
  original_position: '', target_position: '', priority_level: 'normal',
  operation_requirement: '', issue_dept: '中控调度',
}
const form = reactive({ ...defaultForm })

function orderTypeText(t) {
  return { sea_inbound:'海侧进箱', sea_outbound:'海侧出场', land_inbound:'陆侧进箱', land_outbound:'陆侧出场', yard_shift:'场内调箱' }[t] || t
}
function execStatusClass(s) {
  return { issued:'pending', acknowledged:'processing', in_progress:'processing', completed:'completed', cancelled:'warning' }[s] || 'pending'
}
function execStatusDot(s) {
  return { issued:'orange', acknowledged:'blue', in_progress:'blue', completed:'green', cancelled:'red' }[s] || 'orange'
}
function execStatusText(s) {
  return { issued:'待执行', acknowledged:'已确认', in_progress:'执行中', completed:'已完成', cancelled:'已取消' }[s] || s
}

async function fetchData() {
  loading.value = true
  try {
    const data = await getDispatchOrderList({ page_size: 500 })
    list.value = data?.items || []
    stats.total = data?.total || 0
    // 统计待执行和已完成
    stats.pending = list.value.filter(i => i.execution_status === 'issued').length
    stats.completed = list.value.filter(i => i.execution_status === 'completed').length
  } finally {
    loading.value = false
  }
}

function openCreateDialog() {
  // 自动生成指令号
  const now = new Date()
  form.order_id = 'DI-' + now.getFullYear() + String(now.getMonth()+1).padStart(2,'0') + String(now.getDate()).padStart(2,'0') + '-' + String(Math.floor(Math.random()*1000)).padStart(3,'0')
  form.issue_time = new Date().toISOString()
  // 重置其他字段
  form.order_type = 'sea_inbound'
  form.execute_dept = '岸桥班组'
  form.container_id = ''
  form.original_position = ''
  form.target_position = ''
  form.priority_level = 'normal'
  form.operation_requirement = ''
  showModal.value = true
}

async function handleSave() {
  if (!form.target_position) return appStore.showToast('请输入目标位置', 'error')
  try {
    const payload = {
      order_id: form.order_id,
      order_type: form.order_type,
      issue_time: form.issue_time,
      execute_dept: form.execute_dept,
      container_id: form.container_id || null,
      original_position: form.original_position || null,
      target_position: form.target_position,
      priority_level: form.priority_level,
      operation_requirement: form.operation_requirement || null,
      issue_dept: '中控调度',
    }
    await createDispatchOrder(payload)
    showModal.value = false
    appStore.showToast('下发成功', 'success')
    fetchData()
  } catch (_) { /* handled by interceptor */ }
}

onMounted(fetchData)
</script>
