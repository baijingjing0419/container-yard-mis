<template>
  <span class="status-badge" :class="status">
    <span class="dot" :class="dotColor"></span>
    {{ text }}
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, default: 'pending' },  // completed | pending | processing | warning
  text: { type: String, default: '' },
})

const dotColor = computed(() => {
  switch (props.status) {
    case 'completed': return 'green'
    case 'processing': return 'blue'
    case 'pending': return 'orange'
    case 'warning': return 'red'
    default: return 'orange'
  }
})
</script>
