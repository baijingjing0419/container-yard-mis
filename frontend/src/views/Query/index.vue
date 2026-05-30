<template>
  <div class="fade-in">
    <div class="page-title">箱量/状态查询</div>
    <div class="page-subtitle">为船公司、客户、集卡司机提供箱状态查询服务</div>

    <div class="card" style="margin-bottom: 20px;">
      <div class="card-body">
        <div style="display: flex; gap: 15px; align-items: flex-end;">
          <div style="flex: 1;">
            <label style="font-size:13px;font-weight:500;color:#374151;margin-bottom:6px;display:block;">查询类型</label>
            <select v-model="searchType" class="form-input">
              <option value="container_id">按箱号查询</option>
              <option value="ship_name">按船名航次查询</option>
              <option value="slot">按堆位查询</option>
            </select>
          </div>
          <div style="flex: 2;">
            <label style="font-size:13px;font-weight:500;color:#374151;margin-bottom:6px;display:block;">查询内容</label>
            <input v-model="searchKeyword" class="form-input" placeholder="输入箱号、船名或堆位编号..." @keyup.enter="doSearch">
          </div>
          <div>
            <button class="btn btn-primary" style="padding:10px 24px;" @click="doSearch">
              <i class="fas fa-search"></i> 查询
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-title">查询结果 <span v-if="searched" style="color:#94a3b8;font-weight:normal;font-size:13px;">({{ results.length }} 条)</span></div>
        <button class="btn btn-secondary"><i class="fas fa-download"></i> 导出结果</button>
      </div>
      <div class="card-body" style="padding:0;">
        <div v-bind="containerProps" class="virtual-scroll-container">
          <table class="data-table">
            <thead><tr>
              <th>箱号</th><th>箱型</th><th>箱状态</th><th>当前位置</th>
              <th>船名航次</th><th>入场时间</th><th>预计出场</th><th>停留时长</th><th>操作</th>
            </tr></thead>
            <tbody>
              <tr v-if="!searched"><td colspan="9" style="text-align:center;color:#94a3b8;padding:40px;">请输入查询条件后点击"查询"按钮</td></tr>
              <tr v-else-if="loading"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">查询中...</td></tr>
              <tr v-else-if="!results.length"><td colspan="9" style="text-align:center;color:#94a3b8;padding:30px;">未找到匹配记录</td></tr>
              <tr v-for="{ data: item } in virtualResults" :key="item.inventory_id">
                <td><strong style="color:#1e40af;">{{ item.container_id }}</strong></td>
                <td>{{ item.container_type }}</td>
                <td><StatusBadge :status="item.is_overdue ? 'warning' : 'completed'" :text="item.is_overdue ? '超期' : '在堆'" /></td>
                <td>{{ item.slot_label || item.current_slot_id || '--' }}</td>
                <td>{{ item.ship_name || item.ship_id || '--' }}</td>
                <td>{{ item.entry_time ? item.entry_time.substring(0,16) : '--' }}</td>
                <td>{{ item.expected_exit_time ? item.expected_exit_time.substring(0,10) : '--' }}</td>
                <td>{{ item.dwell_time_hours ? item.dwell_time_hours+'小时' : '--' }}</td>
                <td><button class="btn btn-sm btn-secondary"><i class="fas fa-eye"></i> 详情</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useVirtualList } from '@vueuse/core'
import { getInventoryList } from '../../api/yardInventory'
import StatusBadge from '../../components/StatusBadge.vue'

const searchType = ref('container_id')
const searchKeyword = ref('')
const results = ref([])
const loading = ref(false)
const searched = ref(false)

const { list: virtualResults, containerProps, wrapperProps } = useVirtualList(results, { itemHeight: 48, overscan: 10 })

async function doSearch() {
  if (!searchKeyword.value.trim()) {
    alert('请输入查询内容')
    return
  }
  const keyword = searchKeyword.value.trim()
  const params = { page_size: 500 }

  // 按搜索类型构造请求参数
  if (searchType.value === 'container_id') {
    params.container_id = keyword
  } else {
    // 船名和堆位用全量查询后前端过滤（API 暂不支持这些字段的模糊搜索）
    // 使用 getInventoryList 获取全量数据
  }

  loading.value = true
  searched.value = true
  try {
    const data = await getInventoryList(params)
    let items = data?.items || []

    // 前端辅助过滤：ship_name 或 current_slot_id
    if (searchType.value === 'ship_name') {
      items = items.filter(i =>
        (i.ship_name && i.ship_name.includes(keyword)) ||
        (i.ship_id && i.ship_id.includes(keyword))
      )
    } else if (searchType.value === 'slot') {
      items = items.filter(i =>
        (i.slot_label && i.slot_label.includes(keyword)) ||
        (i.current_slot_id && i.current_slot_id.includes(keyword))
      )
    }

    results.value = items
  } catch (_) {
    results.value = []
  } finally {
    loading.value = false
  }
}
</script>
