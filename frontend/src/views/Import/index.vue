<template>
  <div class="fade-in">
    <div class="page-title">数据导入</div>
    <div class="page-subtitle">通过 CSV 文件批量导入员工、船舶、集装箱数据</div>

    <!-- 表选择 -->
    <div class="card" style="margin-bottom:20px;">
      <div style="margin-bottom:12px;font-weight:600;color:#1e293b;">选择导入目标</div>
      <div style="display:flex;gap:8px;flex-wrap:wrap;">
        <button v-for="t in tables" :key="t.key" class="btn" :class="table === t.key ? 'btn-primary' : 'btn-secondary'" style="padding:8px 16px;font-size:13px;" @click="selectTable(t.key)">
          <i :class="t.icon"></i> {{ t.label }}
        </button>
      </div>
    </div>

    <!-- 模板下载 -->
    <div class="card" style="margin-bottom:20px;">
      <div style="display:flex;align-items:center;justify-content:space-between;">
        <div>
          <div style="font-weight:600;color:#1e293b;margin-bottom:4px;">1. 下载模板</div>
          <div style="font-size:13px;color:#94a3b8;">下载带有中文表头的空 CSV 模板</div>
        </div>
        <button class="btn btn-secondary" style="padding:8px 16px;" @click="downloadTemplate">
          <i class="fas fa-download"></i> 下载 {{ currentTable?.label }} 模板
        </button>
      </div>
    </div>

    <!-- 上传 -->
    <div class="card" style="margin-bottom:20px;">
      <div style="font-weight:600;color:#1e293b;margin-bottom:12px;">2. 上传 CSV</div>
      <div class="upload-zone" @drop.prevent="handleDrop" @dragover.prevent>
        <i class="fas fa-cloud-upload-alt" style="font-size:32px;color:#94a3b8;margin-bottom:8px;"></i>
        <p style="color:#64748b;margin:0 0 4px;">将 CSV 文件拖拽到此处，或点击选择</p>
        <p style="color:#94a3b8;font-size:12px;margin:0;">仅支持 .csv 文件，编码请使用 UTF-8</p>
        <input type="file" accept=".csv" @change="handleFileSelect" style="display:none;" ref="fileInput" />
        <button class="btn btn-secondary" style="margin-top:12px;padding:8px 16px;font-size:13px;" @click="($refs.fileInput as HTMLInputElement).click()">
          <i class="fas fa-folder-open"></i> 选择文件
        </button>
      </div>
      <div v-if="file" style="margin-top:12px;padding:10px 14px;background:#f1f5f9;border-radius:8px;font-size:13px;color:#475569;">
        <i class="fas fa-file-csv" style="color:#10b981;"></i> {{ file.name }} ({{ (file.size / 1024).toFixed(1) }} KB)
      </div>
    </div>

    <!-- 上传按钮 -->
    <button class="btn btn-primary" style="padding:12px 32px;font-size:14px;" @click="handleUpload" :disabled="!file || uploading">
      <span v-if="uploading"><i class="fas fa-spinner fa-spin"></i> 导入中...</span>
      <span v-else><i class="fas fa-upload"></i> 开始导入</span>
    </button>

    <!-- 结果 -->
    <div v-if="result" class="card" style="margin-top:20px;">
      <div style="font-weight:600;color:#1e293b;margin-bottom:12px;">导入结果</div>
      <div style="display:flex;gap:20px;margin-bottom:16px;">
        <div class="stat-card" style="flex:1;"><div class="stat-value" style="color:#10b981;">{{ result.imported }}</div><div class="stat-label">成功导入</div></div>
        <div class="stat-card" style="flex:1;"><div class="stat-value" style="color:#ef4444;">{{ result.errors.length }}</div><div class="stat-label">失败</div></div>
        <div class="stat-card" style="flex:1;"><div class="stat-value">{{ result.total }}</div><div class="stat-label">总计</div></div>
      </div>
      <div v-if="result.errors.length > 0">
        <div style="font-weight:600;color:#ef4444;margin-bottom:8px;font-size:13px;">错误详情</div>
        <div v-for="(e, i) in result.errors" :key="i" class="alert alert-warning" style="margin-bottom:4px;font-size:13px;">
          第 {{ e.row }} 行: {{ e.reason }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '../../api/request'

const tables = [
  { key: 'users', label: '员工', icon: 'fas fa-users' },
  { key: 'ships', label: '船舶', icon: 'fas fa-ship' },
  { key: 'containers_master', label: '集装箱', icon: 'fas fa-box' },
]

const table = ref('users')
const file = ref<File | null>(null)
const uploading = ref(false)
const result = ref<any>(null)
const fileInput = ref<HTMLInputElement>()

const currentTable = ref(tables[0])

function selectTable(key: string) {
  table.value = key
  currentTable.value = tables.find(t => t.key === key) || tables[0]
  file.value = null
  result.value = null
}

function downloadTemplate() {
  window.open(`/api/v1/import/templates/${table.value}`, '_blank')
}

function handleFileSelect(e: Event) {
  const input = e.target as HTMLInputElement
  if (input.files?.[0]) file.value = input.files[0]
}

function handleDrop(e: DragEvent) {
  if (e.dataTransfer?.files[0]) file.value = e.dataTransfer.files[0]
}

async function handleUpload() {
  if (!file.value) return
  uploading.value = true
  result.value = null
  try {
    const fd = new FormData()
    fd.append('file', file.value)
    fd.append('table', table.value)
    const { data } = await api.post('/import/csv', fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    result.value = data
  } catch (e: any) {
    result.value = { imported: 0, errors: [{ row: '-', reason: e?.response?.data?.detail || '导入失败' }], total: 1 }
  } finally {
    uploading.value = false
  }
}
</script>

<style scoped>
.card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
.upload-zone { border: 2px dashed #cbd5e1; border-radius: 12px; padding: 32px; display: flex; flex-direction: column; align-items: center; justify-content: center; transition: all .2s; cursor: pointer; }
.upload-zone:hover { border-color: #1e40af; background: #f8fafc; }
.stat-card { text-align: center; padding: 12px; background: #f8fafc; border-radius: 8px; }
.stat-value { font-size: 24px; font-weight: 700; }
.stat-label { font-size: 12px; color: #94a3b8; margin-top: 4px; }
</style>
