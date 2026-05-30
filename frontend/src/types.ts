export interface ContainerMaster {
  container_id: string
  container_type: string
  tare_weight: number | null
  owner_company: string | null
  size_code: string | null
  manufacture_date: string | null
  created_at: string
  updated_at: string
}

export interface ContainerMoveLog {
  log_id: number
  container_id: string
  from_slot_id: string | null
  to_slot_id: string
  move_time: string
  operator_name: string | null
  operation_id: string | null
  equipment_id: string | null
  remark: string | null
  created_at: string
}

export interface YardInventoryItem {
  inventory_id: number
  container_id: string
  container_status: string | null
  current_slot_id: string | null
  previous_slot_id: string | null
  entry_time: string | null
  expected_exit_time: string | null
  actual_exit_time: string | null
  dwell_time_hours: number | null
  ship_id: string | null
  voyage_no: string | null
  is_overdue: boolean | null
  overdue_days: number | null
  alert_level: string | null
  source_type: string | null
  ship_name?: string | null
  slot_label?: string | null
  container_info?: string | null
}

export interface PaginatedItems<T> {
  items: T[]
  total: number
  page: number
  page_size: number
}
