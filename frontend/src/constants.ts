export const ORDER_TYPE_TEXT: Record<string, string> = {
  sea_inbound: '海侧进箱', sea_outbound: '海侧出场', land_inbound: '陆侧进箱', land_outbound: '陆侧出场', yard_shift: '场内调箱',
}

export const EXEC_STATUS: Record<string, { cls: string; text: string }> = {
  issued: { cls: 'pending', text: '待执行' },
  acknowledged: { cls: 'processing', text: '已确认' },
  in_progress: { cls: 'processing', text: '执行中' },
  completed: { cls: 'completed', text: '已完成' },
  cancelled: { cls: 'warning', text: '已取消' },
}

export const LAND_STATUS: Record<string, { cls: string; text: string }> = {
  pending: { cls: 'pending', text: '待处理' },
  gate_checking: { cls: 'processing', text: '核验中' },
  landed: { cls: 'completed', text: '已落箱' },
  completed: { cls: 'completed', text: '已完成' },
}

export const PLAN_STATUS: Record<string, { cls: string; text: string }> = {
  draft: { cls: 'pending', text: '草稿' },
  confirmed: { cls: 'processing', text: '已确认' },
  in_progress: { cls: 'processing', text: '执行中' },
  completed: { cls: 'completed', text: '已完成' },
  cancelled: { cls: 'warning', text: '已取消' },
}

export const OP_TYPE_TEXT: Record<string, string> = {
  shift: '翻箱', land: '落箱', pick: '提箱', flip: '倒箱', inspect: '查验',
}
