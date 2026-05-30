import api from './request'
export const getOperationList = (p) => api.get('/yard-operations', { params: p }).then(r => r.data)
export const createOperation = (d) => api.post('/yard-operations', d).then(r => r.data)
