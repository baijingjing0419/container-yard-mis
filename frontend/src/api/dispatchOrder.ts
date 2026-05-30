import api from './request'

export interface DispatchOrder {
  order_id: string
  order_type: string
  execute_dept?: string
  container_id?: string | null
  original_position?: string | null
  target_position: string
  priority_level?: string
  operation_requirement?: string | null
  issue_time?: string
  issue_dept?: string
}

export function getDispatchOrderList(params: Record<string, unknown> = {}): Promise<{ items: DispatchOrder[]; total: number }> {
  return api.get('/dispatch-orders', { params }).then(r => r.data)
}

export function createDispatchOrder(data: Partial<DispatchOrder>): Promise<DispatchOrder> {
  return api.post('/dispatch-orders', data).then(r => r.data)
}
