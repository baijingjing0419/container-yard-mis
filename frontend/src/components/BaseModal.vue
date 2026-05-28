<template>
  <div class="modal-overlay" :class="{ active: visible }" @click.self="$emit('close')">
    <div class="modal">
      <div class="modal-header">
        <div class="modal-title">{{ title }}</div>
        <div class="modal-close" @click="$emit('close')"><i class="fas fa-times"></i></div>
      </div>
      <div class="modal-body">
        <slot />
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" @click="$emit('close')">取消</button>
        <button class="btn btn-primary" @click="$emit('save')">
          <i class="fas fa-save"></i> 保存
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: { type: String, default: '新增记录' },
  visible: { type: Boolean, default: false },
})
defineEmits(['close', 'save'])
</script>
