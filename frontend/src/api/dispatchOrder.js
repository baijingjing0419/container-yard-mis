import api from './request'

export function getDispatchOrderList(params = {}) {
  return api.get('/dispatch-orders', { params }).then(r => r.data)
}

export function createDispatchOrder(data) {
  return api.post('/dispatch-orders', data).then(r => r.data)
}
