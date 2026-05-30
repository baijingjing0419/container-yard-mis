import api from './request'
export const getInventoryList = (p) => api.get('/yard-inventory', { params: p }).then(r => r.data)
export const createInventory = (d) => api.post('/yard-inventory', d).then(r => r.data)
